extends "res://personagens/personagem_base.gd"
signal vida_atualizada(vida_atual, vida_maxima)
signal player_morreu
signal cargas_cura_mudou(cargas_restantes)
signal energia_mudou(energia_atual, energia_maxima)

@onready var mira_sprite: Sprite2D = $textura/Mira
@onready var cone_de_mira: Area2D = $ConeDeMira
@onready var health_component: HealthComponent = $HealthComponent
@onready var audio_arco_puxar: AudioStreamPlayer2D = $AudioArcoPuxar
@onready var audio_cast_magia: AudioStreamPlayer2D = $AudioCastMagia

@export var cena_flecha: PackedScene 
@export var cena_missil_de_fogo: PackedScene


var is_aiming: bool = false
var is_in_action: bool = false
var is_dead: bool = false
var cargas_de_cura: int = 3
var energia_maxima: float = 100.0
var energia_atual: float = 0.0
var custo_golpe_duplo: float = 50.0 # Quanto custa o golpe
var current_attack_damage = 25.0
var alvo_travado: Node2D = null


func _ready():
	health_component.morreu.connect(_on_morte)
	health_component.vida_mudou.connect(_on_health_component_vida_mudou)
	_animation.animation_finished.connect(_on_animation_finished)
	emit_signal.call_deferred("vida_atualizada", health_component.vida_atual, health_component.vida_maxima)
	emit_signal.call_deferred("cargas_cura_mudou", cargas_de_cura)
	emit_signal.call_deferred("energia_mudou", energia_atual, energia_maxima)
	# Não precisamos mais conectar o timer!
	
func _on_morte():
	if is_dead:
		return

	is_dead = true
	is_in_action = true 
	set_physics_process(false) 

	var anim_sufixo = "_f" 
	if _face_direction == 1: anim_sufixo = "_c" 
	elif _face_direction == 2: anim_sufixo = "_p"

	_animation.play("morte" + anim_sufixo)
	$AudioDead.play()
	
	$colisao.set_deferred("disabled", true)
	emit_signal("player_morreu")
	
	# --- CÓDIGO DO ZOOM ---
	var tween = create_tween()
	tween.tween_property($Camera2D, "zoom", Vector2(1.5, 1.5), 2.0).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	# --- MUDANÇA AQUI ---
	# CARREGA A TELA DE MORTE IMEDIATAMENTE!
	# (A LINHA 'await tween.finished' FOI REMOVIDA!)
	var game_over_scene = load("res://HUD/game_over_screen.tscn") # (Confirme seu caminho!)
	var game_over_instance = game_over_scene.instantiate()
	add_child(game_over_instance)
	
	Logger.log("O PLAYER MORREU!")
# [Em: player.gd]
# (Substitua sua _physics_process inteira por esta)

func _physics_process(delta):

	# 1. Checagem de Pausa
	if Input.is_action_just_pressed("ui_accept"):
		var pause_menu_scene = load("res://HUD/pause_menu.tscn")
		var pause_instance = pause_menu_scene.instantiate()
		add_child(pause_instance)
		get_tree().paused = true
		return

	# 3. Pegar Direção
	var anim_sufixo = "_f" 
	if _face_direction == 1:
		anim_sufixo = "_c" 
	elif _face_direction == 2:
		anim_sufixo = "_p"

	# --- 4. LÓGICA DE AÇÕES (Prioridade Total) ---
	
	if is_in_action:
		pass 

	# --- AÇÕES DE MIRA (LT - Ação "equip_arco") ---
	elif Input.is_action_pressed("equip_arco"):
		
		if not is_aiming:
			audio_arco_puxar.play()
		
		is_aiming = true 
		audio_cast_magia.stop() 

		audio_passos_areia.stop()
		audio_passos_grama.stop()

		_atualizar_alvo_com_cone(anim_sufixo)
		
		if alvo_travado != null:
			mira_sprite.visible = true
			mira_sprite.global_position = alvo_travado.global_position
		else:
			mira_sprite.visible = false
		
		if Input.is_action_just_pressed("ataque_primario"): # LT + X
			is_in_action = true 
			_animation.play("arco_disparo" + anim_sufixo) 
			_disparar_flecha(anim_sufixo) 
			audio_arco_puxar.stop() 
			Logger.log("Player usou ARCO SIMPLES!")
			
		elif Input.is_action_just_pressed("ataque_especial"): # LT + Y
			if round(energia_atual) >= custo_golpe_duplo:
				energia_atual -= custo_golpe_duplo
				emit_signal("energia_mudou", energia_atual, energia_maxima)
				is_in_action = true 
				audio_arco_puxar.stop() 
				_animation.play("arco_disparo" + anim_sufixo)
				_disparar_rajada_de_flechas(anim_sufixo)
				Logger.log("Player usou RAJADA DE FLECHAS!")
			else:
				Logger.log("Sem energia para a Rajada de Flechas!")
		else:
			_animation.play("arco_mira" + anim_sufixo)

	# --- AÇÕES DE MAGIA (RT - Ação "equip_magia") ---
	elif Input.is_action_pressed("equip_magia"):
		
		if not is_aiming: 
			audio_cast_magia.play()
			_animation.play("magia_fogo" + anim_sufixo)
		
		is_aiming = true 
		audio_arco_puxar.stop()

		audio_passos_areia.stop()
		audio_passos_grama.stop()

		_atualizar_alvo_com_cone(anim_sufixo)
		
		if alvo_travado != null:
			mira_sprite.visible = true
			mira_sprite.global_position = alvo_travado.global_position
		else:
			mira_sprite.visible = false

		if Input.is_action_just_pressed("ataque_primario"): # RT + X
			is_in_action = true 
			_animation.play("magia_fogo" + anim_sufixo)
			_disparar_missil(anim_sufixo) 
			Logger.log("Player usou MÍSSIL DE FOGO!")
			
		elif Input.is_action_just_pressed("ataque_especial"): # RT + Y
			if round(energia_atual) >= custo_golpe_duplo:
				energia_atual -= custo_golpe_duplo
				emit_signal("energia_mudou", energia_atual, energia_maxima)
				is_in_action = true
				_animation.play("magia_fogo" + anim_sufixo)
				_disparar_leque_de_misseis(anim_sufixo)
				Logger.log("Player usou LEQUE DE FOGO!")
			else:
				Logger.log("Sem energia para o Leque de Fogo!")
		else:
			pass

	# --- AÇÕES PADRÃO (Sem modificador) ---
	else:
		if is_aiming:
			audio_arco_puxar.stop() 
			audio_cast_magia.stop()
			mira_sprite.visible = false 
			alvo_travado = null
			
			# --- O POLIMENTO DO "CANCELAR" ESTÁ AQUI! ---
			# Se a animação atual é uma de "mira" (arco) ou 
			# "canalizar" (fogo), e nós NÃO acabamos de atirar...
			if not is_in_action and ( \
			   _animation.current_animation.begins_with("arco_mira_") or \
			   _animation.current_animation.begins_with("magia_fogo_") \
			   ):
				
				# ... Cancela ela e volta pro "idle" IMEDIATAMENTE!
				_animation.play("idle" + anim_sufixo)
			# --- FIM DA CORREÇÃO ---
			
		is_aiming = false

		if Input.is_action_just_pressed("curar"):
			if cargas_de_cura > 0:
				cargas_de_cura -= 1
				is_in_action = true 
				_animation.play("magia_cura" + anim_sufixo)
				health_component.curar(25.0)
				emit_signal("cargas_cura_mudou", cargas_de_cura)
				Logger.log("Cura usada! Restam: %s" % cargas_de_cura)
			else:
				Logger.log("Sem cargas de cura!")

		elif Input.is_action_just_pressed("ataque_primario"):
			is_in_action = true
			current_attack_damage = 25.0
			_animation.play("espada" + anim_sufixo)
			Logger.log("Player usou ATAQUE SIMPLES!")

		elif Input.is_action_just_pressed("ataque_especial"):
			if round(energia_atual) >= custo_golpe_duplo:
				energia_atual -= custo_golpe_duplo
				emit_signal("energia_mudou", energia_atual, energia_maxima)
				is_in_action = true
				current_attack_damage = 50.0
				_animation.play("espada_duplo" + anim_sufixo)
				Logger.log("Golpe Duplo usado!")
			else:
				Logger.log("Sem energia para o Golpe Duplo!")

	# --- 5. LÓGICA DE MOVIMENTO ---
	if not is_in_action and not is_aiming:
		super(delta) 
	else:
		velocity = Vector2.ZERO
		move_and_slide()

func _on_animation_finished(anim_name: String):
	
	# --- CORREÇÃO PARTE 2 AQUI ---
	if anim_name.begins_with("espada_") or \
	   anim_name.begins_with("magia_cura_") or \
	   anim_name.begins_with("espada_duplo_") or \
	   anim_name.begins_with("hurt_") or \
	   anim_name.begins_with("arco_disparo_") or \
	   anim_name.begins_with("magia_fogo_"): 
		
		is_in_action = false # DESTRAVA o player
func _on_hit_box_espada_body_entered(body: Node2D) -> void:
	# 1. Checa se o que acertamos tem o "adesivo" que criamos
	if body.is_in_group("damageable_enemy"):
		
		# 2. Calcula a direção do ataque (do player para o inimigo)
		var direcao_do_ataque = (body.global_position - global_position).normalized()
		
		# 3. Chama a função que JÁ EXISTE no inimigo!
		body.sofrer_dano(current_attack_damage, direcao_do_ataque)
		
		Logger.log("ACERTEI O INIMIGO: %s" % body.name)
func receber_dano_do_inimigo(dano: float, direcao_do_ataque: Vector2):
	# Se já estivermos mortos ou no meio de uma ação (como rolar, no futuro)
	if health_component.vida_atual == 0.0 or is_in_action:
		return 

	# 1. Aplica o dano
	health_component.sofrer_dano(dano)
	
	# 2. SE NÃO MORREU, toca a animação "hurt_"
	if health_component.vida_atual > 0.0:
		is_in_action = true # Trava o player para ele não andar
		
		# Pega a direção DE ONDE VEIO O ATAQUE para a animação
		var anim_sufixo = "_f" 
		if direcao_do_ataque.y < -0.5: # Veio de cima (acertou as costas)
			anim_sufixo = "_c"
		elif abs(direcao_do_ataque.x) > 0.5: # Veio dos lados
			anim_sufixo = "_p"
		# (Se veio de baixo, usa "_f" mesmo)

		_animation.play("hurt" + anim_sufixo) # <-- SUAS ANIMAÇÕES!
		
		# (Opcional: Adicionar um leve knockback)
		velocity = direcao_do_ataque * 300.0 # Ajustar valor
		
	# Esta função "ouve" o sinal INTERNO do HealthComponent...
func _on_health_component_vida_mudou(vida_atual: float, vida_maxima: float):
	
	# ...e "grita" o SINAL PÚBLICO para o mundo exterior (o GameLevel)
	emit_signal("vida_atualizada", vida_atual, vida_maxima)
# --- NOVA FUNÇÃO ---
# O GerenciadorDeTerreno vai chamar isso quando um inimigo morrer
func ganhar_energia(quantidade: float):
	# Adiciona energia, sem passar do máximo
	energia_atual = min(energia_maxima, energia_atual + quantidade)

	# Avisa o HUD que a energia mudou!
	emit_signal("energia_mudou", energia_atual, energia_maxima)
	Logger.log("Energia ganha! Total: %s" % int(energia_atual))
# [Em: player.gd]
# (Nova função, coloque no final do script)
# [Em: player.gd]

func _disparar_flecha(sufixo_anim: String):
	if cena_flecha == null:
		push_warning("Cena da Flecha não configurada no Player!")
		return

	var flecha = cena_flecha.instantiate()
	var direcao_disparo: Vector2

	# --- LÓGICA DE DIREÇÃO ATUALIZADA ---
	
	# 1. Se temos um alvo travado...
	if alvo_travado != null:
		# ... a direção é do player ATÉ o alvo!
		direcao_disparo = (alvo_travado.global_position - global_position).normalized()

	# 2. Se NÃO temos alvo (tiro cego)...
	else:
		# ... a direção é para onde o player está olhando (como era antes).
		if sufixo_anim == "_c":
			direcao_disparo = Vector2.UP
		elif sufixo_anim == "_p":
			direcao_disparo = Vector2.RIGHT if not _sprite.flip_h else Vector2.LEFT
		else: # Padrão (sufixo "_f")
			direcao_disparo = Vector2.DOWN

	flecha.direcao = direcao_disparo
	
	# 2. Define a Posição Inicial
	flecha.global_position = global_position 
	
	# 3. Adiciona a flecha na cena principal
	get_parent().add_child(flecha)
# [Em: player.gd]
# (Nova função, coloque no final do script)

# --- NOVA FUNÇÃO (Substitui a _atualizar_alvo_com_raycast) ---
# Atualiza o alvo baseado no inimigo mais próximo dentro do ConeDeMira.
func _atualizar_alvo_com_cone(sufixo_anim: String):
	# 1. Gira o cone para apontar na direção do player
	# (0 rad = baixo, -PI/2 = esquerda, PI/2 = direita, PI = cima)
	if sufixo_anim == "_c":
		cone_de_mira.rotation = PI
	elif sufixo_anim == "_p":
		# Usamos o flip do sprite para saber se é esquerda ou direita
		cone_de_mira.rotation = PI / 2.0 if _sprite.flip_h else -PI / 2.0
	else: # Padrão (sufixo "_f")
		cone_de_mira.rotation = 0

	# 2. Pega todos os inimigos que estão DENTRO do cone
	var corpos_no_cone = cone_de_mira.get_overlapping_bodies()
	
	# 3. Se não tem ninguém, limpa o alvo
	if corpos_no_cone.is_empty():
		alvo_travado = null
		return

	# 4. Se tem inimigos, acha o MAIS PRÓXIMO
	var inimigo_mais_proximo: Node2D = null
	var menor_distancia_quadrada: float = INF # Começa com infinito
	
	for corpo in corpos_no_cone:
		# Checa se o corpo é um inimigo válido (do grupo)
		if corpo.is_in_group("damageable_enemy"):
			var dist_quadrada = global_position.distance_squared_to(corpo.global_position)
			
			if dist_quadrada < menor_distancia_quadrada:
				menor_distancia_quadrada = dist_quadrada
				inimigo_mais_proximo = corpo

	# 5. Define o alvo
	alvo_travado = inimigo_mais_proximo
# --- NOVA FUNÇÃO (Para o Ataque Especial do Arco) ---
func _disparar_rajada_de_flechas(sufixo_anim: String):
	if cena_flecha == null:
		push_warning("Cena da Flecha não configurada no Player!")
		return

	# Vamos usar um Timer para disparar as flechas
	# com um pequeno atraso entre elas (0.1s)
	
	# Dispara a Flecha 1 (Imediata)
	_disparar_flecha(sufixo_anim) 
	
	# Dispara a Flecha 2 (Após 0.1s)
	await get_tree().create_timer(0.1).timeout
	# (Checa se o player ainda está vivo e mirando)
	if is_dead or not is_aiming: return
	_disparar_flecha(sufixo_anim)

	# Dispara a Flecha 3 (Após 0.1s)
	await get_tree().create_timer(0.1).timeout
	if is_dead or not is_aiming: return
	_disparar_flecha(sufixo_anim)

# [Em: player.gd]
# (Adicione estas DUAS novas funções no final do script)

# (Dispara UM míssil de fogo - RT+X)
func _disparar_missil(sufixo_anim: String):
	if cena_missil_de_fogo == null:
		push_warning("Cena do Míssil de Fogo não configurada no Player!")
		return

	var missil = cena_missil_de_fogo.instantiate()
	var direcao_disparo: Vector2

	# --- LÓGICA DE DIREÇÃO (Idêntica à da flecha) ---
	# 1. Se temos um alvo travado...
	if alvo_travado != null:
		direcao_disparo = (alvo_travado.global_position - global_position).normalized() #[cite: 34]
	# 2. Se NÃO temos alvo (tiro cego)...
	else:
		if sufixo_anim == "_c": #[cite: 35]
			direcao_disparo = Vector2.UP
		elif sufixo_anim == "_p": #[cite: 35]
			direcao_disparo = Vector2.RIGHT if not _sprite.flip_h else Vector2.LEFT
		else: # Padrão (sufixo "_f")
			direcao_disparo = Vector2.DOWN #[cite: 35]
	# --- FIM DA LÓGICA DE DIREÇÃO ---

	missil.direcao = direcao_disparo
	missil.global_position = global_position 
	get_parent().add_child(missil)
# [Em: player.gd]
# (Substitua SÓ esta função)

# (Dispara o LEQUE de mísseis - RT+Y)
# --- VERSÃO "ARQUITETO" (Com Loop!) ---
func _disparar_leque_de_misseis(sufixo_anim: String):
	if cena_missil_de_fogo == null:
		push_warning("Cena do Míssil de Fogo não configurada no Player!")
		return

	# --- NOSSAS NOVAS VARIÁVEIS DE CONTROLE ---
	# (É SÓ MUDAR AQUI PARA TER MAIS MÍSSEIS!)
	var quantidade_misseis: int = 5 # (Use 3, 5, 7... números ímpares!)
	var angulo_passo: float = deg_to_rad(10) # 10 graus entre cada míssil
	# --- FIM DAS VARIÁVEIS ---
	
	var direcao_base: Vector2

	# (A lógica "burra" de direção continua igual)
	if sufixo_anim == "_c":
		direcao_base = Vector2.UP
	elif sufixo_anim == "_p":
		direcao_base = Vector2.RIGHT if not _sprite.flip_h else Vector2.LEFT
	else: # Padrão (sufixo "_f")
		direcao_base = Vector2.DOWN
	
	# --- A MÁGICA DO LOOP ---
	# (Calcula o ângulo do primeiro míssil, o mais à esquerda)
	var angulo_inicial: float = -(quantidade_misseis / 2) * angulo_passo
	
	for i in range(quantidade_misseis):
		# 1. Calcula o ângulo deste míssil
		var angulo_offset = angulo_inicial + (i * angulo_passo)
		var direcao_atual = direcao_base.rotated(angulo_offset)
		
		# 2. Cria o míssil
		var missil = cena_missil_de_fogo.instantiate()
		missil.direcao = direcao_atual
		missil.global_position = global_position
		get_parent().add_child(missil)
	# --- FIM DO LOOP ---
