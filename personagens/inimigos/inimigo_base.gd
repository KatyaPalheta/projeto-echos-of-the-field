# [Script: inimigo_base.gd] (VERSÃO REATORADA)
extends CharacterBody2D
class_name InimigoBase

# --- Componentes (como no player) ---
@onready var animacao: AnimationPlayer = $Animacao
@onready var health_component: HealthComponent = $HealthComponent 
@onready var textura: Sprite2D = $Textura
@onready var attack_timer: Timer = $AttackTimer
@onready var audio_hurt: AudioStreamPlayer2D = $AudioHit
@onready var efeito_queimadura: Sprite2D = $EfeitoQueimadura
@onready var efeito_queimadura_anim: AnimationPlayer = $EfeitoQueimadura/AnimationPlayer
@onready var sinal_alerta: Sprite2D = $SinalAlerta
@onready var audio_alerta: AudioStreamPlayer2D = $AudioAlerta
@onready var alerta_timer: Timer = $AlertaTimer
@onready var dot_timer: Timer = $DoTTimer
@onready var audio_queimadura: AudioStreamPlayer2D = $AudioQueimadura




# --- A GRANDE MUDANÇA: Referência para a StateMachine ---
@onready var state_machine: Node = get_node_or_null("StateMachine")
@onready var health_bar: ProgressBar = $InimigoHealthBar

# --- Variáveis de Estado (AGORA SÃO GLOBAIS) ---
var face_direction: Vector2 = Vector2.DOWN
var player_target: Node2D = null
var is_dead: bool = false # (Para evitar dano duplo, etc)

# --- Stats Base (cada inimigo pode mudar isso) ---
@export var move_speed: float = 50.0
@export var attack_damage: float = 10.0
@export var knockback_force: float = 400.0

var dot_dano_por_tick: float = 0.0
var dot_duracao_restante: float = 0.0


func _ready():
	
	_setup_dificuldade() 
	
	add_to_group("inimigos")
	alerta_timer.timeout.connect(_on_alerta_timer_timeout)
	dot_timer.timeout.connect(_on_dot_timer_timeout)
	
	health_component.morreu.connect(_on_morte)
	health_component.vida_mudou.connect(_on_inimigo_vida_mudou)

	pass



func _setup_dificuldade():
	
	if GameManager.onda_atual_index == 0 and GameManager.inimigos_total_na_onda == 0:
		return
	var mult_vida = ConfigManager.get_gameplay_value("multiplicador_vida_monstro")
	var mult_dano = ConfigManager.get_gameplay_value("multiplicador_dano_monstro")
	if mult_vida == null: mult_vida = 1.0 
	if mult_dano == null: mult_dano = 1.0 

	
	var dificuldade_progressiva = ConfigManager.config_data.dificuldade_progressiva
	var onda_atual = GameManager.onda_atual_index + 1
	
	var fator_progressao = 1.0
	if dificuldade_progressiva:

		fator_progressao = sqrt(float(onda_atual))
		

	health_component.vida_maxima = max(1.0, health_component.vida_maxima * mult_vida * fator_progressao)
	health_component.vida_atual = health_component.vida_maxima
	

	attack_damage = max(1.0, attack_damage * mult_dano * fator_progressao)
	
	Logger.log.call_deferred("Inimigo Spawnado: Vida Final: %s (Dano: %s)" % [int(health_component.vida_maxima), int(attack_damage)])

	_on_inimigo_vida_mudou(health_component.vida_atual, health_component.vida_maxima)
func sofrer_dano(dano: float, direcao_do_ataque: Vector2):

	# ⚠️ CORREÇÃO BUG #1: Checa a flag de morte ANTES de fazer qualquer coisa.
	if is_dead:
		return

	health_component.sofrer_dano(dano)

	if audio_hurt != null:
		audio_hurt.play()
		
	# A segunda checagem 'if is_dead: return' não é mais necessária aqui,
	# pois health_component.sofrer_dano(dano) cuida da emissão do sinal 'morreu'.
	# Se a morte aconteceu, o _on_morte() foi chamado.

	var estado_atual_str = state_machine.current_state.name
	if estado_atual_str == "Hurt":
		return 
		
	var hurt_state = state_machine.get_node("Hurt")
	hurt_state.setup_knockback(direcao_do_ataque)
	state_machine._change_state(hurt_state)

func _on_morte():
	# 1. Checagem defensiva e marcação IMEDIATA.
	if is_dead: return 
	is_dead = true
	
	# ⚠️ CORREÇÃO BUG #2 PARTE 1: Paramos a lógica do inimigo/state machine imediatamente.
	set_physics_process(false) 
	if is_instance_valid(state_machine):
		state_machine.set_physics_process(false) 

	# 2. REGISTRA A MORTE DE FORMA DEFERIDA (Bug #1: Previne contagem dupla)
	if GameManager != null:
		GameManager.call_deferred("registrar_morte_inimigo") 
	
	# 3. Transição para o estado "Dead" e forçamos a animação.
	if is_instance_valid(state_machine):
		# Mudar para o estado Dead. 
		state_machine._change_state(state_machine.get_node("Dead"))
	
	# ⚠️ CORREÇÃO BUG #2 PARTE 2: Garante a animação e o cleanup forçado.
	if is_instance_valid(animacao):
		# Pega o sufixo baseado na última direção de face (do Slime ou Inimigo)
		var sufixo = _get_suffix_from_direction(face_direction) 
		var anim_name = "dead" + sufixo # Ex: "dead_f"

		if animacao.animation_finished.is_connected(_cleanup_after_death):
			animacao.animation_finished.disconnect(_cleanup_after_death)
		
		# Conecta o sinal à função que removerá o inimigo.
		animacao.animation_finished.connect(_cleanup_after_death)
		
		# Força a animação de morte (com o nome corrigido).
		animacao.play(anim_name) 
	
	# 4. Esconde a barra de vida.
	if health_bar != null:
		health_bar.visible = false

func _cleanup_after_death(_anim_name: String):
	
	queue_free()

func _get_suffix_from_direction(direction: Vector2) -> String:
	# Se o movimento Y (vertical) for o mais forte...
	if abs(direction.y) > abs(direction.x):
		if direction.y < 0:
			return "_c" # Cima (costas)
		else:
			return "_f" # Baixo (frente)
	# Se o movimento X (horizontal) for o mais forte...
	else:
		if direction.x != 0:
			# Lógica de flip (movida do smile.gd para cá)
			if direction.x > 0.1:
				textura.flip_h = true # Indo para Direita
			elif direction.x < -0.1:
				textura.flip_h = false # Indo para Esquerda
			return "_p" # Perfil
		else:
			# Se não tiver direção (parado), usa a frente
			return "_f"

# --- Lógica de Detecção (sem mudança) ---

func _on_zona_de_deteccao_body_entered(body: Node2D) -> void:
	if body is PersonagemBase:
		player_target = body
		
		# Só toca o alerta se estivermos passivos
		var estado_atual_str = state_machine.current_state.name
		if estado_atual_str == "Idle" or estado_atual_str == "Wander":
			sinal_alerta.visible = true
			audio_alerta.play()
			alerta_timer.start()

func _on_zona_de_deteccao_body_exited(body: Node2D) -> void:
	if body == player_target:
		player_target = null 

func _on_hit_box_ataque_body_entered(body: Node2D) -> void:
	if body is PersonagemBase:
		var direcao_do_ataque = (body.global_position - global_position).normalized()
		body.receber_dano_do_inimigo(attack_damage, direcao_do_ataque)

func fugir_do_player(posicao_do_player: Vector2):
	if is_dead:
		return
	
	var flee_state = state_machine.get_node("Flee")
	flee_state.setup_flee(posicao_do_player)
	state_machine._change_state(flee_state)

func _on_alerta_timer_timeout() -> void:
	sinal_alerta.visible = false

# --- Lógica de Queimadura (sem mudança) ---

func aplicar_queimadura(dano_por_segundo: float, duracao_total: float):
	if is_dead:
		return
	if audio_hurt != null:
		audio_hurt.play()

	dot_dano_por_tick = dano_por_segundo
	dot_duracao_restante = duracao_total
	
	if not audio_queimadura.playing:
		audio_queimadura.play()
		
	if efeito_queimadura != null:
		efeito_queimadura.visible = true
		if efeito_queimadura_anim != null:
			efeito_queimadura_anim.play("queimar") 
	
	dot_timer.start(1.0)

# [Em: inimigo_base.gd]
# (SUBSTITUA ESTA FUNÇÃO INTEIRA)

func _on_dot_timer_timeout():
	# --- CORREÇÃO DO BUG DO DoT ---
	# (Movemos o dano para ANTES da checagem de parada)
	
	# 1. Aplica o dano do tick que ACABOU de acontecer
	if health_component != null:
		health_component.sofrer_dano(dot_dano_por_tick)
	
	# 2. Reduz a duração
	dot_duracao_restante -= 1.0
	
	# 3. Checa se a duração acabou
	# (Ex: 1.0 vira 0.0, checa 0.0 <= 0.0, para. O dano já foi aplicado)
	if dot_duracao_restante <= 0.0:
		_parar_queimadura()
		return # Não reinicia o timer
	# --- FIM DA CORREÇÃO ---
	
	# 4. Se não acabou, reinicia o timer
	dot_timer.start(1.0)
	
func _parar_queimadura():
	dot_timer.stop()
	audio_queimadura.stop()
	dot_duracao_restante = 0.0
	
	if efeito_queimadura != null:
		efeito_queimadura.visible = false
		if efeito_queimadura_anim != null:
			efeito_queimadura_anim.stop()
# [Em: inimigo_base.gd]
# (Adicione estas duas funções de volta)

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:

	set_physics_process(true)
	

	if is_instance_valid(state_machine):

		state_machine.set_physics_process(true)

	animacao.set_process(true)


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:

	set_physics_process(false)
	

	if is_instance_valid(state_machine):

		state_machine.set_physics_process(false)


	# Pausa o processamento do AnimationPlayer
	animacao.set_process(false)


func _on_inimigo_vida_mudou(vida_atual: float, vida_maxima: float):
	if health_bar != null:
		

		if not health_bar.visible:
			
			health_bar.visible = true
			
			health_bar.max_value = vida_maxima 
		
		health_bar.value = vida_atual
