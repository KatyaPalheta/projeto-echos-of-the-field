extends "res://personagens/personagem_base.gd"
signal vida_atualizada(vida_atual, vida_maxima)
signal player_morreu
signal cargas_cura_mudou(cargas_restantes)
signal energia_mudou(energia_atual, energia_maxima)

@onready var health_component: HealthComponent = $HealthComponent
# @onready var double_click_timer: Timer = $DoubleClickTimer <-- REMOVIDO!
var is_in_action: bool = false
var is_dead: bool = false
var cargas_de_cura: int = 3
var energia_maxima: float = 100.0
var energia_atual: float = 0.0
var custo_golpe_duplo: float = 50.0 # Quanto custa o golpe
var current_attack_damage = 25.0


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

func _physics_process(delta):

	if Input.is_action_just_pressed("ui_accept"):
		# 1. Carrega a cena do menu de pause
		var pause_menu_scene = load("res://HUD/pause_menu.tscn") # <-- CONFIRME O CAMINHO!
		var pause_instance = pause_menu_scene.instantiate()
		
		# 2. Adiciona o menu à tela
		add_child(pause_instance)
		
		# 3. Pausa o jogo (o menu vai assumir daqui)
		get_tree().paused = true
		
		# 4. Para de processar o player neste frame
		return
	if is_in_action:
		return # Pula todo o resto da função [cite: 52]

	# --- 1. Lógica de Movimento (só roda se NÃO estiver em ação) ---
	super(delta) 

	# --- 2. Lógica de Animação (vamos pegar a direção) ---
	var anim_sufixo = "_f" 
	if _face_direction == 1:
		anim_sufixo = "_c" 
	elif _face_direction == 2:
		anim_sufixo = "_p"

	# --- 3. Lógica de Ações (LÓGICA NOVA E RESPONSIVA) ---

	# Checa se o player está SEGURANDO o botão do ARCO (LB)
	if Input.is_action_pressed("equip_arco"):
		
		if Input.is_action_just_pressed("ataque_primario"): # LB + X
			is_in_action = true
			# _animation.play("arco_simples" + anim_sufixo)
			Logger.log("Player usou ARCO SIMPLES!")
			
		elif Input.is_action_just_pressed("ataque_especial"): # LB + Y
			is_in_action = true
			# _animation.play("arco_chuva" + anim_sufixo)
			Logger.log("Player usou CHUVA DE FLECHA!")

	# Checa se o player está SEGURANDO o botão de MAGIA (RB)
	elif Input.is_action_pressed("equip_magia"):
		
		if Input.is_action_just_pressed("ataque_primario"): # RB + X
			is_in_action = true
			# _animation.play("magia_fogo_simples" + anim_sufixo)
			Logger.log("Player usou FOGO SIMPLES!")
			
		elif Input.is_action_just_pressed("ataque_especial"): # RB + Y
			is_in_action = true
			# _animation.play("magia_fogo_master" + anim_sufixo)
			Logger.log("Player usou FOGO MASTER BLASTER!")

	# --- Ações Padrão (sem modificador pressionado) ---

	# Ação de Cura (Botão B)
	# Ação de Cura (Botão B) - LÓGICA ATUALIZADA
	elif Input.is_action_just_pressed("curar"):
		
		# 1. Checa se o player PODE se curar
		if cargas_de_cura > 0:
			# 2. Gasta a carga
			cargas_de_cura -= 1
			
			# 3. Executa a cura
			is_in_action = true 
			_animation.play("magia_cura" + anim_sufixo) 
			health_component.curar(25.0)
			emit_signal("cargas_cura_mudou", cargas_de_cura)
			
			# (Vamos adicionar o sinal para o HUD no próximo passo!)
			Logger.log("Cura usada! Restam: %s" % cargas_de_cura)
			
		else:
			# 4. Acabaram as cargas
			Logger.log("Sem cargas de cura!")
			# (Aqui podemos tocar um som de "falha" no futuro)

	# ( ... sua lógica de cura (Botão B) vem antes daqui ... ) [cite: 53, 59-60]

	# Ação de Ataque Simples (Botão X) - LÓGICA ATUALIZADA
	elif Input.is_action_just_pressed("ataque_primario"):
		is_in_action = true
		current_attack_damage = 25.0 # <-- CORREÇÃO IMPORTANTE! (Reseta o dano)
		_animation.play("espada" + anim_sufixo)
		Logger.log("Player usou ATAQUE SIMPLES!")

	# Ação de Ataque Duplo/Especial (Botão Y) - LÓGICA ATUALIZADA
	elif Input.is_action_just_pressed("ataque_especial"):
		
		# 1. Checa se temos energia suficiente (usando round() para evitar bugs)
		if round(energia_atual) >= custo_golpe_duplo:
			# 2. Gasta a energia
			energia_atual -= custo_golpe_duplo
			emit_signal("energia_mudou", energia_atual, energia_maxima) # Avisa o HUD [cite: 61]
			
			# 3. Executa o golpe
			is_in_action = true
			current_attack_damage = 50.0 # Dano dobrado! [cite: 61]
			_animation.play("espada_duplo" + anim_sufixo)
			Logger.log("Golpe Duplo usado!")
			
		else:
			# 4. Sem energia (AGORA CORRIGIDO - SÓ AVISA!)
			Logger.log("Sem energia para o Golpe Duplo!")
			# (O código duplicado de ataque foi removido daqui!)

func _on_animation_finished(anim_name: String):
	
	# Checa se a animação que terminou é uma de "ação"
	# (Adicione os nomes das animações de arco/magia aqui quando as tiver)
	if anim_name.begins_with("espada_") or \
	   anim_name.begins_with("magia_cura_") or \
	   anim_name.begins_with("espada_duplo_") or \
	   anim_name.begins_with("hurt_"): # <-- ADICIONE ISSO AQUI
		
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
