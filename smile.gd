extends InimigoBase # <-- HERDA DO NOSSO MOLDE!

@export_category("Randomização do Slime")
@export var lista_texturas: Array[Texture2D]

# --- Variáveis do Pulo do Slime ---
@export var jump_cooldown: float = 3.0   # Tempo parado
@export var jump_duration: float = 0.5   # Tempo pulando

var chosen_jump_direction: Vector2 = Vector2.RIGHT # Guarda a direção do pulo
var directions_list: Array[Vector2] = [
	Vector2.UP, 
	Vector2.DOWN, 
	Vector2.LEFT, 
	Vector2.RIGHT
]
@onready var jump_timer: Timer = $JumpTimer # (Vamos criar esse Timer)

func _ready():
	super() # <-- IMPORTANTE: Chama o _ready() do inimigo_base

	# --- LÓGICA DO SORTEIO (SUA IDEIA CORRETA!) ---
	# Sorteia qual spritesheet completo vamos usar
	if not lista_texturas.is_empty():
		# 'textura' é a var que herdamos do 'inimigo_base'!
		textura.texture = lista_texturas.pick_random()
	# --- FIM DO SORTEIO ---

	current_state = State.IDLE
	jump_timer.start(jump_cooldown) # Começa o timer para o primeiro puloo

func _physics_process(delta):
	# A IA principal do Slime (pular e parar)

	# --- LÓGICA DE ESTADO (HURT/DEAD/ATTACK) ---
	# (Essa parte de cima, que checa HURT/DEAD/ATTACK, continua igual)
	if current_state == State.DEAD or current_state == State.ATTACK:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	if current_state == State.HURT:
		velocity = velocity.move_toward(Vector2.ZERO, 1500 * delta)
		move_and_slide()
		return 

	# --- LÓGICA DE ANIMAÇÃO (A PARTE NOVA!) ---
	# Pega o sufixo da direção que estamos olhando (que está na "memória")
	# Nós herdamos a função _get_suffix_from_direction do 'inimigo_base'!
	var anim_sufixo = _get_suffix_from_direction(face_direction)

	# --- LÓGICA DE MOVIMENTO (Atualizada) ---
	match current_state:
		State.IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, 100 * delta) # Freia
			animacao.play("idle" + anim_sufixo) # <-- CORRIGIDO!

		State.WANDER: # WANDER = "Pular"
			velocity = velocity.move_toward(chosen_jump_direction * move_speed, 100 * delta) 
			animacao.play("jump" + anim_sufixo) # <-- CORRIGIDO!

	move_and_slide()


# O Timer nos avisa quando mudar de estado
func _on_jump_timer_timeout():
	if current_state == State.IDLE:
		# Estava parado? Começa a pular.
		current_state = State.WANDER
		chosen_jump_direction = directions_list.pick_random() # SORTEIA A DIREÇÃO!
		face_direction = chosen_jump_direction
		jump_timer.start(jump_duration)
	elif current_state == State.WANDER:
		# Estava pulando? Começa a parar.
		current_state = State.IDLE
		jump_timer.start(randf_range(0.1, jump_cooldown))
