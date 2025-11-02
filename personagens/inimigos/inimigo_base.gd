extends CharacterBody2D
class_name InimigoBase # <-- Muito útil para o futuro!

signal morreu_e_deu_energia(valor)

# --- Componentes (como no player) ---
@onready var animacao: AnimationPlayer = $Animacao
@onready var health_component: HealthComponent = $HealthComponent 
@onready var textura: Sprite2D = $Textura
@onready var attack_timer: Timer = $AttackTimer

@onready var sinal_alerta: Sprite2D = $SinalAlerta
@onready var audio_alerta: AudioStreamPlayer2D = $AudioAlerta
@onready var alerta_timer: Timer = $AlertaTimer

# --- Variáveis de Estado ---
# Vamos usar isso para controlar (parado, andando, atacando, morrendo)
enum State { IDLE, WANDER, CHASE, ATTACK, HURT, DEAD, FLEE }
var current_state: State = State.IDLE
var face_direction: Vector2 = Vector2.DOWN
var player_target: Node2D = null

# --- Stats Base (cada inimigo pode mudar isso) ---
@export var move_speed: float = 50.0
@export var attack_damage: float = 10.0
@export var knockback_force: float = 400.0

func _ready():
	# Conecta o sinal de morte do HealthComponent 
	add_to_group("inimigos")
	health_component.morreu.connect(_on_morte)
	animacao.animation_finished.connect(_on_animation_finished)
	alerta_timer.timeout.connect(_on_alerta_timer_timeout)
	set_physics_process(false)
	animacao.set_process(false)
	#visible = false


# Esta é a função que o player vai chamar para causar dano
func sofrer_dano(dano: float, direcao_do_ataque: Vector2):
	if current_state == State.DEAD:
		return 

	health_component.sofrer_dano(dano)

	# --- CORREÇÃO DO BUG DE ORDEM ---
	# O sinal "morreu" já pode ter sido emitido e mudado nosso estado.
	# Se já morremos, pare aqui! Não toque a animação "hurt".
	if current_state == State.DEAD:
		return # Deixa a função _on_morte cuidar do resto.

	# --- LÓGICA ATUALIZADA ---
	# Se chegamos aqui, é porque NÃO morremos (só tomamos dano).
	# Pega o sufixo da direção DE ONDE VEIO O ATAQUE
	var anim_sufixo = _get_suffix_from_direction(direcao_do_ataque)

	current_state = State.HURT
	animacao.play("hurt" + anim_sufixo) # Ex: "hurt_p"
	velocity = direcao_do_ataque * knockback_force


# Esta função é chamada pelo SINAL do HealthComponent
func _on_morte():
	current_state = State.DEAD
	animacao.play("dead" + _get_suffix_from_direction(face_direction))
	emit_signal("morreu_e_deu_energia", 25.0)

	# (Aqui vamos desativar colisões e fazer ele sumir)
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
			return "_p" # Perfil
		else:
			# Se não tiver direção (parado), usa a frente
			return "_f"
# --- NOVA FUNÇÃO ---
# Chamada quando QUALQUER animação do inimigo termina
func _on_animation_finished(anim_name: String):
	# Se o inimigo JÁ ESTIVER MORTO, ignore todo o resto
	# exceto a animação de morte.
	if current_state == State.DEAD:
		if anim_name.begins_with("dead_"):
			queue_free()
			Logger.log("Smile morreu!") # Se autodestrói
		return # Ignora todo o resto (como o "hurt_")

	# --- Se ele NÃO ESTIVER MORTO, continua normal ---
	
	# Se a animação que acabou foi a de "tomar dano"...
	if anim_name.begins_with("hurt_"):
		
		# LÓGICA ATUALIZADA:
		# Se o player AINDA ESTIVER no nosso radar (player_target não é nulo)...
		if player_target != null:
			# ...então volte a PERSEGUIR!
			current_state = State.CHASE
		else:
			# ...senão, AGORA SIM, volte ao estado normal (parado)
			current_state = State.IDLE


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	# Ativa a física e a IA
	set_physics_process(true)
	# Ativa o processamento do AnimationPlayer
	animacao.set_process(true) # Replace with function body.
	#visible = true


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	# Desativa a física e a IA (ECONOMIZA MUITO CPU!)
	set_physics_process(false)
	# Pausa o processamento do AnimationPlayer (ECONOMIZA MAIS CPU!)
	animacao.set_process(false) # Replace with function body.
	#visible = false





func _on_zona_de_deteccao_body_entered(body: Node2D) -> void:
	# Checa se quem entrou é o Player (usando a classe base)
	if body is PersonagemBase:
		player_target = body # Guarda o alvo!
		var estava_passivo = (current_state == State.IDLE or current_state == State.WANDER)
		# Só muda para CHASE se não estivermos sendo atingidos ou morrendo
		if current_state != State.HURT and current_state != State.DEAD:
			current_state = State.CHASE
			if estava_passivo:
				sinal_alerta.visible = true
				audio_alerta.play()
				alerta_timer.start() # Inicia o timer de 0.5s


func _on_zona_de_deteccao_body_exited(body: Node2D) -> void:
	# Checa se quem saiu é o MESMO alvo que estávamos perseguindo
	if body == player_target:
		player_target = null # Esquece o alvo
		
		# Se estávamos perseguindo, voltamos a ficar parados
		if current_state == State.CHASE:
			current_state = State.IDLE


func _on_hit_box_ataque_body_entered(body: Node2D) -> void:
	if body is PersonagemBase:
		
		# 2. Calcula a direção do ataque (do inimigo PARA o player)
		var direcao_do_ataque = (body.global_position - global_position).normalized()
		
		# 3. Chama uma NOVA função no player para ele tomar o dano
		#    (Nós vamos criar essa função no próximo passo!)
		#    [cite_start]Usamos a variável 'attack_damage' que já existe no inimigo! [cite: 9]
		body.receber_dano_do_inimigo(attack_damage, direcao_do_ataque) # Replace with function body.
# Esta função será chamada pelo GameLevel
func fugir_do_player(posicao_do_player: Vector2):
	if current_state == State.DEAD:
		return # Morto não foge

	current_state = State.FLEE
	player_target = null # Para de perseguir

	# Calcula a direção OPOSTA ao player
	var flee_direction = (global_position - posicao_do_player).normalized()

	# Define a velocidade de fuga (ex: 1.5x mais rápido)
	velocity = flee_direction * (move_speed * 1.5)
	# Esta função é chamada pelo sinal 'timeout' do AlertaTimer
func _on_alerta_timer_timeout() -> void:
	# Esconde o "!"
	sinal_alerta.visible = false
