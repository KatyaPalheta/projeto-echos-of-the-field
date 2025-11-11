# [Script: player.gd]
extends "res://personagens/personagem_base.gd"

signal vida_atualizada(vida_atual, vida_maxima)
signal player_morreu
signal cargas_cura_mudou(cargas_restantes)
signal energia_mudou(energia_atual, energia_maxima)

# --- Referências de Componentes ---
@onready var mira_sprite: Sprite2D = $textura/Mira
@onready var cone_de_mira: Area2D = $ConeDeMira
@onready var health_component: HealthComponent = $HealthComponent
@onready var audio_arco_puxar: AudioStreamPlayer2D = $AudioArcoPuxar
@onready var audio_cast_magia: AudioStreamPlayer2D = $AudioCastMagia

# --- Referência da Máquina de Estados ---
@onready var state_machine = $StateMachine

# --- Cenas de Ataque ---
@export var cena_flecha: PackedScene 
@export var cena_missil_de_fogo: PackedScene

# --- Variáveis de Estado do Player ---
var is_dead: bool = false # (is_in_action e is_aiming não são mais necessárias aqui!)
var cargas_de_cura: int = 3
var energia_maxima: float = 100.0
var energia_atual: float = 0.0
var custo_golpe_duplo: float = 50.0 
var current_attack_damage = 25.0
var alvo_travado: Node2D = null


func _ready():
	health_component.morreu.connect(_on_morte)
	health_component.vida_mudou.connect(_on_health_component_vida_mudou)
	_animation.animation_finished.connect(_on_animation_finished)
	
	emit_signal.call_deferred("vida_atualizada", health_component.vida_atual, health_component.vida_maxima)
	emit_signal.call_deferred("cargas_cura_mudou", cargas_de_cura)
	emit_signal.call_deferred("energia_mudou", energia_atual, energia_maxima)
	
	# (A lógica do _ready do StateMachine vai cuidar de iniciar os estados)


# --- O NOVO PHYSICS PROCESS (AGORA DELEGA) ---
func _physics_process(delta):
	# 1. Checagem de Pausa (Isso fica aqui, é global)
	if Input.is_action_just_pressed("ui_pausar"):
		var pause_menu_scene = load("res://HUD/pause_menu.tscn")
		var pause_instance = pause_menu_scene.instantiate()
		add_child(pause_instance)
		get_tree().paused = true
		return

	# 2. Se estamos mortos, nenhum estado importa
	if is_dead:
		velocity = Vector2.ZERO
		move_and_slide()
		return
		
	# 3. DELEGA o processamento para o estado atual
	# (O 'super(delta)' foi MOVIDO para o PlayerMove.gd)
	# (Toda a lógica de if/elif de ações foi REMOVIDA)
	pass # O StateMachine (que é nosso filho) já roda seu _physics_process


# --- O NOVO INPUT PROCESS (AGORA DELEGA) ---
func _input(event):
	# DELEGA o input para o estado atual
	pass # O StateMachine (que é nosso filho) já roda seu _input


# --- FUNÇÕES DE MORTE E DANO (Isso não muda) ---

func _on_morte():
	if is_dead:
		return

	is_dead = true
	# (is_in_action = true) -> REMOVIDO
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


func receber_dano_do_inimigo(dano: float, direcao_do_ataque: Vector2):
	# (A checagem de 'is_in_action' foi REMOVIDA,
	#  vamos colocar uma checagem melhor no estado HURT)
	if health_component.vida_atual == 0.0:
		return 

	health_component.sofrer_dano(dano)
	
	if health_component.vida_atual > 0.0:
		# (is_in_action = true) -> REMOVIDO
		
		# (NO FUTURO: state_machine._change_state("Hurt") )
		
		var anim_sufixo = "_f" 
		if direcao_do_ataque.y < -0.5: 
			anim_sufixo = "_c"
		elif abs(direcao_do_ataque.x) > 0.5: 
			anim_sufixo = "_p"

		_animation.play("hurt" + anim_sufixo) 
		velocity = direcao_do_ataque * 300.0
		
	
func _on_animation_finished(anim_name: String):
	# (A lógica 'is_in_action = false' foi REMOVIDA)
	# (No futuro, o *próprio estado* vai ouvir esse sinal
	#  para saber quando ele deve transicionar de volta ao Idle)
	pass


# --- FUNÇÕES DE HITBOX E SINAIS (Isso não muda) ---

func _on_hit_box_espada_body_entered(body: Node2D) -> void:
	if body.is_in_group("damageable_enemy"):
		var direcao_do_ataque = (body.global_position - global_position).normalized()
		body.sofrer_dano(current_attack_damage, direcao_do_ataque)
		Logger.log("ACERTEI O INIMIGO: %s" % body.name)

func _on_health_component_vida_mudou(vida_atual: float, vida_maxima: float):
	emit_signal("vida_atualizada", vida_atual, vida_maxima)

func ganhar_energia(quantidade: float):
	energia_atual = min(energia_maxima, energia_atual + quantidade)
	emit_signal("energia_mudou", energia_atual, energia_maxima)
	Logger.log("Energia ganha! Total: %s" % int(energia_atual))


# --- FUNÇÕES "HELPER" DE DISPARO ---
# (Elas ficam aqui! Os estados de ataque vão chamar estas funções)

func _disparar_flecha(sufixo_anim: String):
	if cena_flecha == null:
		push_warning("Cena da Flecha não configurada no Player!")
		return

	var flecha = cena_flecha.instantiate()
	var direcao_disparo: Vector2

	if alvo_travado != null:
		direcao_disparo = (alvo_travado.global_position - global_position).normalized()
	else:
		if sufixo_anim == "_c":
			direcao_disparo = Vector2.UP
		elif sufixo_anim == "_p":
			direcao_disparo = Vector2.RIGHT if not _sprite.flip_h else Vector2.LEFT
		else: 
			direcao_disparo = Vector2.DOWN

	flecha.direcao = direcao_disparo
	flecha.global_position = global_position 
	get_parent().add_child(flecha)


func _atualizar_alvo_com_cone(sufixo_anim: String):
	if sufixo_anim == "_c":
		cone_de_mira.rotation = PI
	elif sufixo_anim == "_p":
		cone_de_mira.rotation = PI / 2.0 if _sprite.flip_h else -PI / 2.0
	else: 
		cone_de_mira.rotation = 0

	var corpos_no_cone = cone_de_mira.get_overlapping_bodies()
	
	if corpos_no_cone.is_empty():
		alvo_travado = null
		return

	var inimigo_mais_proximo: Node2D = null
	var menor_distancia_quadrada: float = INF 
	
	for corpo in corpos_no_cone:
		if corpo.is_in_group("damageable_enemy"):
			var dist_quadrada = global_position.distance_squared_to(corpo.global_position)
			
			if dist_quadrada < menor_distancia_quadrada:
				menor_distancia_quadrada = dist_quadrada
				inimigo_mais_proximo = corpo

	alvo_travado = inimigo_mais_proximo


func _disparar_rajada_de_flechas(sufixo_anim: String):
	if cena_flecha == null:
		push_warning("Cena da Flecha não configurada no Player!")
		return

	_disparar_flecha(sufixo_anim) 
	
	await get_tree().create_timer(0.1).timeout
	if is_dead: return # (Não checa mais 'is_aiming')
	_disparar_flecha(sufixo_anim)

	await get_tree().create_timer(0.1).timeout
	if is_dead: return
	_disparar_flecha(sufixo_anim)


func _disparar_missil(sufixo_anim: String):
	if cena_missil_de_fogo == null:
		push_warning("Cena do Míssil de Fogo não configurada no Player!")
		return

	var missil = cena_missil_de_fogo.instantiate()
	var direcao_disparo: Vector2

	if alvo_travado != null:
		direcao_disparo = (alvo_travado.global_position - global_position).normalized()
	else:
		if sufixo_anim == "_c":
			direcao_disparo = Vector2.UP
		elif sufixo_anim == "_p":
			direcao_disparo = Vector2.RIGHT if not _sprite.flip_h else Vector2.LEFT
		else: 
			direcao_disparo = Vector2.DOWN

	missil.direcao = direcao_disparo
	missil.global_position = global_position 
	get_parent().add_child(missil)


func _disparar_leque_de_misseis(sufixo_anim: String):
	if cena_missil_de_fogo == null:
		push_warning("Cena do Míssil de Fogo não configurada no Player!")
		return

	var quantidade_misseis: int = 3 
	var angulo_passo: float = deg_to_rad(10) 
	var direcao_base: Vector2

	if sufixo_anim == "_c":
		direcao_base = Vector2.UP
	elif sufixo_anim == "_p":
		direcao_base = Vector2.RIGHT if not _sprite.flip_h else Vector2.LEFT
	else: 
		direcao_base = Vector2.DOWN
	
	var angulo_inicial: float = -(quantidade_misseis / 2.0) * angulo_passo
	
	for i in range(quantidade_misseis):
		var angulo_offset = angulo_inicial + (i * angulo_passo)
		var direcao_atual = direcao_base.rotated(angulo_offset)
		
		var missil = cena_missil_de_fogo.instantiate()
		missil.direcao = direcao_atual
		missil.global_position = global_position
		get_parent().add_child(missil)
