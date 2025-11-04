extends "res://personagens/personagem_base.gd"

# --- SINAIS ---
signal vida_atualizada(vida_atual, vida_maxima)
signal player_morreu
signal cargas_cura_mudou(cargas_restantes)
signal energia_mudou(energia_atual, energia_maxima)

# --- COMPONENTES ---
@onready var health_component: HealthComponent = $HealthComponent
@onready var zona_de_mira: Area2D = $ZonaDeMira
@onready var audio_arco_carregar: AudioStreamPlayer2D = $AudioArcoCarregar
@onready var audio_arco_disparar: AudioStreamPlayer2D = $AudioArcoDisparar
@onready var ponto_disparo: Marker2D = $PontoDisparo

# --- CENAS ---
@export var reticulo_scene: PackedScene
@export var flecha_scene: PackedScene # (Movido da função para cá)

# --- VARIÁVEIS DE ESTADO ---
var is_in_action: bool = false
var is_dead: bool = false
var cargas_de_cura: int = 3
var energia_maxima: float = 100.0
var energia_atual: float = 0.0
var custo_golpe_duplo: float = 50.0
var current_attack_damage = 25.0

# --- VARIÁVEIS DE MIRA ---
var alvos_na_zona: Array[Node2D] = []
var alvo_travado: Node2D = null
var reticulo_instance: Node2D = null


func _ready():
	health_component.morreu.connect(_on_morte)
	health_component.vida_mudou.connect(_on_health_component_vida_mudou)
	_animation.animation_finished.connect(_on_animation_finished)
	
	emit_signal.call_deferred("vida_atualizada", health_component.vida_atual, health_component.vida_maxima)
	emit_signal.call_deferred("cargas_cura_mudou", cargas_de_cura)
	emit_signal.call_deferred("energia_mudou", energia_atual, energia_maxima)
	
	zona_de_mira.body_entered.connect(_on_zona_de_mira_body_entered)
	zona_de_mira.body_exited.connect(_on_zona_de_mira_body_exited)

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
	
	var tween = create_tween()
	tween.tween_property($Camera2D, "zoom", Vector2(1.5, 1.5), 2.0).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	var game_over_scene = load("res://HUD/game_over_screen.tscn")
	var game_over_instance = game_over_scene.instantiate()
	add_child(game_over_instance)
	
	Logger.log("O PLAYER MORREU!")


# ##############################################################################
#  FUNÇÃO _PHYSICS_PROCESS (VERSÃO CORRIGIDA E LIMPA)
# ##############################################################################

func _physics_process(delta):

	# 1. CHECAGEM DE PAUSE
	if Input.is_action_just_pressed("ui_accept"):
		var pause_menu_scene = load("res://HUD/pause_menu.tscn")
		var pause_instance = pause_menu_scene.instantiate()
		add_child(pause_instance)
		get_tree().paused = true
		return

	# 2. CHECAGEM DE MORTE
	if is_dead:
		return

	# 3. LÓGICA DE TRAVA DE MIRA (ARCO)
	# Pressionou LB
	if Input.is_action_just_pressed("equip_arco"):
		_travar_alvo_inicial()

	# Soltou LB
	if Input.is_action_just_released("equip_arco"):
		_destravar_alvo()

	# Segurando LB (e travado em um alvo)
	if alvo_travado != null:
		is_in_action = true
		velocity = Vector2.ZERO
		move_and_slide()

		if Input.is_action_just_pressed("move_esquerda") or Input.is_action_just_pressed("move_direita"):
			_trocar_alvo()

		_virar_para_o_alvo()
		var anim_sufixo_arco = _get_sufixo_from_direction(alvo_travado.global_position - global_position)

		# Ataque Simples (X)
		if Input.is_action_just_pressed("ataque_primario"):
			is_in_action = true
			audio_arco_carregar.stop()
			audio_arco_disparar.play()
			_animation.play("arco_disparar" + anim_sufixo_arco)
			_shoot_arrow(alvo_travado) 

		# Ataque Especial (Y)
		elif Input.is_action_just_pressed("ataque_especial"):
			is_in_action = true
			audio_arco_carregar.stop()
			_animation.play("arco_disparar" + anim_sufixo_arco)
			_shoot_arrow_burst(alvo_travado)

		# Mirando (Idle)
		elif not _animation.current_animation.begins_with("arco_disparar_"):
			_animation.play("arco_carregar" + anim_sufixo_arco)
			if not audio_arco_carregar.playing:
				audio_arco_carregar.play()

		return # <-- Pula todo o resto (movimento, espada, etc.)

	# 4. CHECAGEM DE AÇÃO (Se não estamos mirando, mas estamos em outra ação)
	if is_in_action:
		return 

	# 5. LÓGICA DE MOVIMENTO (Só roda se não estiver em ação)
	super(delta) 

	# 6. LÓGICA DE ANIMAÇÃO DE MOVIMENTO (Pega o sufixo para as ações)
	var anim_sufixo_mov = "_f" 
	if _face_direction == 1:
		anim_sufixo_mov = "_c" 
	elif _face_direction == 2:
		anim_sufixo_mov = "_p"

	# 7. AÇÕES (Magia, Cura, Espada)
	
	# Checa Magia (RB)
	if Input.is_action_pressed("equip_magia"):
		
		if Input.is_action_just_pressed("ataque_primario"): # RB + X
			is_in_action = true
			# _animation.play("magia_fogo_simples" + anim_sufixo_mov)
			Logger.log("Player usou FOGO SIMPLES!")
			
		elif Input.is_action_just_pressed("ataque_especial"): # RB + Y
			is_in_action = true
			# _animation.play("magia_fogo_master" + anim_sufixo_mov)
			Logger.log("Player usou FOGO MASTER BLASTER!")

	# Ação de Cura (Botão B)
	elif Input.is_action_just_pressed("curar"):
		if cargas_de_cura > 0:
			cargas_de_cura -= 1
			is_in_action = true 
			_animation.play("magia_cura" + anim_sufixo_mov) 
			health_component.curar(25.0)
			emit_signal("cargas_cura_mudou", cargas_de_cura)
			Logger.log("Cura usada! Restam: %s" % cargas_de_cura)
		else:
			Logger.log("Sem cargas de cura!")

	# Ação de Ataque Simples (Botão X)
	elif Input.is_action_just_pressed("ataque_primario"):
		is_in_action = true
		current_attack_damage = 25.0
		_animation.play("espada" + anim_sufixo_mov)
		Logger.log("Player usou ATAQUE SIMPLES!")

	# Ação de Ataque Duplo/Especial (Botão Y)
	elif Input.is_action_just_pressed("ataque_especial"):
		if round(energia_atual) >= custo_golpe_duplo:
			energia_atual -= custo_golpe_duplo
			emit_signal("energia_mudou", energia_atual, energia_maxima)
			is_in_action = true
			current_attack_damage = 50.0 
			_animation.play("espada_duplo" + anim_sufixo_mov)
			Logger.log("Golpe Duplo usado!")
		else:
			Logger.log("Sem energia para o Golpe Duplo!")


# ##############################################################################
#  RESTANTE DAS FUNÇÕES (NÃO MUDARAM)
# ##############################################################################

func _on_animation_finished(anim_name: String):
	
	# Se a animação de DISPARO (Animação 2) terminar...
	if anim_name.begins_with("arco_disparar_"):
		
		# Se o jogador AINDA ESTIVER SEGURANDO LB (alvo_travado != null)...
		if alvo_travado != null:
			# Volta para a animação de "carregar" (Animação 1)
			var anim_sufixo = _get_sufixo_from_direction(alvo_travado.global_position - global_position)
			_animation.play("arco_carregar" + anim_sufixo)
			audio_arco_carregar.play() # Começa o som de carregar de novo
		else:
			# Se ele soltou o botão, destrava o player
			is_in_action = false 
		
		# Não podemos destravar o 'is_in_action' aqui sempre
		# A lógica acima cuida disso.
		
	
	# Checa se a animação que terminou é uma de "ação"
	elif anim_name.begins_with("espada_") or \
	   anim_name.begins_with("magia_cura_") or \
	   anim_name.begins_with("espada_duplo_") or \
	   anim_name.begins_with("hurt_"):
		
		is_in_action = false # DESTRAVA o player


func _on_hit_box_espada_body_entered(body: Node2D) -> void:
	if body.is_in_group("damageable_enemy"):
		var direcao_do_ataque = (body.global_position - global_position).normalized()
		body.sofrer_dano(current_attack_damage, direcao_do_ataque)
		Logger.log("ACERTEI O INIMIGO: %s" % body.name)

func receber_dano_do_inimigo(dano: float, direcao_do_ataque: Vector2):
	if health_component.vida_atual == 0.0 or is_in_action:
		return 

	health_component.sofrer_dano(dano)
	
	if health_component.vida_atual > 0.0:
		is_in_action = true 
		
		var anim_sufixo = "_f" 
		if direcao_do_ataque.y < -0.5:
			anim_sufixo = "_c"
		elif abs(direcao_do_ataque.x) > 0.5:
			anim_sufixo = "_p"

		_animation.play("hurt" + anim_sufixo)
		velocity = direcao_do_ataque * 300.0
		
func _on_health_component_vida_mudou(vida_atual: float, vida_maxima: float):
	emit_signal("vida_atualizada", vida_atual, vida_maxima)

func ganhar_energia(quantidade: float):
	energia_atual = min(energia_maxima, energia_atual + quantidade)
	emit_signal("energia_mudou", energia_atual, energia_maxima)
	Logger.log("Energia ganha! Total: %s" % int(energia_atual))


# --- FUNÇÕES DE DISPARO ---
func _shoot_arrow(target: Node2D) -> void:
	if not flecha_scene:
		push_warning("Cena da Flecha não configurada no Player!")
		return

	var angle = (target.global_position - ponto_disparo.global_position).angle()
	var flecha = flecha_scene.instantiate()
	flecha.global_position = ponto_disparo.global_position
	flecha.rotation = angle
	flecha.direcao = Vector2.from_angle(angle)
	get_tree().root.add_child(flecha)

func _shoot_arrow_burst(target: Node2D) -> void:
	if not flecha_scene:
		push_warning("Cena da Flecha não configurada no Player!")
		return

	var angle = (target.global_position - ponto_disparo.global_position).angle()
	var direcao = Vector2.from_angle(angle)

	for i in 3:
		var flecha = flecha_scene.instantiate()
		flecha.global_position = ponto_disparo.global_position
		flecha.rotation = angle
		flecha.direcao = direcao
		get_tree().root.add_child(flecha)
		await get_tree().create_timer(0.1).timeout

# --- FUNÇÕES DE TRAVA DE MIRA (LOCK-ON) ---
func _on_zona_de_mira_body_entered(body: Node2D):
	if body.is_in_group("damageable_enemy"):
		if not alvos_na_zona.has(body):
			alvos_na_zona.append(body)

func _on_zona_de_mira_body_exited(body: Node2D):
	if alvos_na_zona.has(body):
		alvos_na_zona.erase(body)
	
	if body == alvo_travado:
		_destravar_alvo()

func _get_forward_vector() -> Vector2:
	match _face_direction:
		0: return Vector2.DOWN
		1: return Vector2.UP
		2: return Vector2.LEFT if _sprite.flip_h else Vector2.RIGHT
	return Vector2.DOWN

func _filtrar_alvos_frontais() -> Array[Node2D]:
	var alvos_frontais: Array[Node2D] = []
	var player_fwd_vec = _get_forward_vector()

	for alvo in alvos_na_zona:
		if not is_instance_valid(alvo):
			continue
		
		var dir_to_alvo = (alvo.global_position - global_position).normalized()
		var dot_product = player_fwd_vec.dot(dir_to_alvo)
		
		if dot_product > 0.3:
			alvos_frontais.append(alvo)
			
	alvos_frontais.sort_custom(
		func(a, b):
			return a.global_position.distance_to(global_position) < b.global_position.distance_to(global_position)
	)
	return alvos_frontais

func _travar_alvo_inicial():
	var alvos_possiveis = _filtrar_alvos_frontais()
	if alvos_possiveis.is_empty():
		return 
		
	alvo_travado = alvos_possiveis[0]
	
	if reticulo_scene:
		reticulo_instance = reticulo_scene.instantiate()
		var ponto_anexo = alvo_travado.find_child("PontoDoReticulo")
		if ponto_anexo:
			ponto_anexo.add_child(reticulo_instance)
		else:
			alvo_travado.add_child(reticulo_instance)

func _destravar_alvo():
	if reticulo_instance:
		reticulo_instance.queue_free()

	reticulo_instance = null
	alvo_travado = null
	is_in_action = false
	audio_arco_carregar.stop()

func _trocar_alvo():
	var alvos_possiveis = _filtrar_alvos_frontais()
	if alvos_possiveis.size() <= 1:
		return 
		
	var current_index = alvos_possiveis.find(alvo_travado)
	var new_index = (current_index + 1) % alvos_possiveis.size()
	
	_destravar_alvo()
	
	alvo_travado = alvos_possiveis[new_index]
	if reticulo_scene:
		reticulo_instance = reticulo_scene.instantiate()
		var ponto_anexo = alvo_travado.find_child("PontoDoReticulo")
		if ponto_anexo:
			ponto_anexo.add_child(reticulo_instance)
		else:
			alvo_travado.add_child(reticulo_instance)

func _virar_para_o_alvo():
	var dir_to_alvo = (alvo_travado.global_position - global_position)

	if abs(dir_to_alvo.y) > abs(dir_to_alvo.x):
		_sprite.flip_h = false
		_hitbox_espada.scale.x = 1
		if dir_to_alvo.y < 0:
			_face_direction = 1
		else:
			_face_direction = 0
	else:
		_face_direction = 2
		_sprite.flip_h = (dir_to_alvo.x < 0)
		_hitbox_espada.scale.x = -1 if _sprite.flip_h else 1

func _get_sufixo_from_direction(direction: Vector2) -> String:
	if abs(direction.y) > abs(direction.x):
		if direction.y < 0: return "_c"
		else: return "_f"
	else:
		if direction.x != 0: return "_p"
		else: return "_f"
