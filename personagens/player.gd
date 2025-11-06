extends "res://personagens/personagem_base.gd"
signal vida_atualizada(vida_atual, vida_maxima)
signal player_morreu
signal cargas_cura_mudou(cargas_restantes)
signal energia_mudou(energia_atual, energia_maxima)

@onready var health_component: HealthComponent = $HealthComponent
@onready var audio_arco_puxar: AudioStreamPlayer2D = $AudioArcoPuxar
@export var cena_flecha: PackedScene 
@onready var mira_sprite: Sprite2D = $textura/Mira
@onready var aim_raycast: RayCast2D = $AimRaycast 

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
# [Em: player.gd]

func _physics_process(delta):

	# 1. Checagem de Pausa
	if Input.is_action_just_pressed("ui_accept"):
		var pause_menu_scene = load("res://HUD/pause_menu.tscn")
		var pause_instance = pause_menu_scene.instantiate()
		add_child(pause_instance)
		get_tree().paused = true
		return

	# 2. Checagem de "Em Ação"
	if is_in_action:
		# (NOVO!) Se estamos em ação (ex: atirando), escondemos a mira
		if mira_sprite.visible:
			mira_sprite.visible = false
			alvo_travado = null
		return 

	# 3. Pegar Direção
	var anim_sufixo = "_f" 
	if _face_direction == 1:
		anim_sufixo = "_c" 
	elif _face_direction == 2:
		anim_sufixo = "_p"

	# --- 4. LÓGICA DE AÇÕES (Prioridade Total) ---

	# --- AÇÕES DE MIRA (LB) ---
	if Input.is_action_pressed("equip_arco"):
		
		if not is_aiming:
			audio_arco_puxar.play() 
		
		is_aiming = true 

		# --- LÓGICA DO RAYCAST (AQUI!) ---
		_atualizar_alvo_com_raycast(anim_sufixo)
		
		# --- LÓGICA DA MIRA VISUAL (AQUI!) ---
		if alvo_travado != null:
			mira_sprite.visible = true
			mira_sprite.global_position = alvo_travado.global_position
		else:
			mira_sprite.visible = false
		# --- FIM DA LÓGICA DE MIRA ---

		
		if Input.is_action_just_pressed("ataque_primario"): # LB + X
			is_in_action = true 
			_animation.play("arco_disparo" + anim_sufixo) 
			_disparar_flecha(anim_sufixo) # (Agora vai usar o alvo_travado!)
			audio_arco_puxar.stop() 
			Logger.log("Player usou ARCO SIMPLES!")
			
		elif Input.is_action_just_pressed("ataque_especial"): # LB + Y
			audio_arco_puxar.stop() 
			Logger.log("Player usou CHUVA DE FLECHA (Ainda não implementado)!")

		else:
			_animation.play("arco_mira" + anim_sufixo) 

	# --- AÇÕES DE MAGIA (RB) ---
	elif Input.is_action_pressed("equip_magia"):
		is_aiming = false 
		audio_arco_puxar.stop()
		mira_sprite.visible = false # (NOVO!) Esconde a mira
		alvo_travado = null       # (NOVO!) Esquece o alvo
		pass

	# --- AÇÕES PADRÃO (Sem modificador) ---
	else:
		if is_aiming:
			audio_arco_puxar.stop() 
			mira_sprite.visible = false # (NOVO!) Esconde a mira
			alvo_travado = null       # (NOVO!) Esquece o alvo
		
		is_aiming = false 

		# ... (lógica de cura, espada, etc. continua igual) ...
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

func _on_animation_finished(anim_name: String):
	
	# Checa se a animação que terminou é uma de "ação"
	if anim_name.begins_with("espada_") or \
	   anim_name.begins_with("magia_cura_") or \
	   anim_name.begins_with("espada_duplo_") or \
	   anim_name.begins_with("hurt_") or \
	   anim_name.begins_with("arco_disparo_"): # <-- MUDANÇA AQUI
		
		# Nota: "arco_mira_" NÃO está aqui.
		# Isso é intencional! A mira só para quando você solta o botão LB.
		
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

func _atualizar_alvo_com_raycast(sufixo_anim: String):
	# 1. Aponta o RayCast na direção correta
	var comprimento_raio = aim_raycast.target_position.x # (Pega o 100 que configuramos)
	
	if sufixo_anim == "_c":
		aim_raycast.target_position = Vector2(0, -comprimento_raio)
	elif sufixo_anim == "_p":
		var dir_x = comprimento_raio if not _sprite.flip_h else -comprimento_raio
		aim_raycast.target_position = Vector2(dir_x, 0)
	else: # Padrão (sufixo "_f")
		aim_raycast.target_position = Vector2(0, comprimento_raio)

	# 2. Força o RayCast a checar AGORA
	aim_raycast.force_raycast_update()

	# 3. Checa o resultado
	if aim_raycast.is_colliding():
		var corpo = aim_raycast.get_collider()
		# Checa se o que acertamos é um inimigo válido
		if corpo.is_in_group("damageable_enemy"):
			alvo_travado = corpo
			return # Achamos um alvo!
			
	# 4. Se não colidiu, ou não era um inimigo...
	alvo_travado = null # ...esquecemos o alvo.
