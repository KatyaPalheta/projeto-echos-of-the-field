extends InimigoBase # <-- HERDA DO NOSSO MOLDE!

@export_category("Randomização do Slime")
@export var lista_texturas: Array[Texture2D]

# --- Variáveis do Pulo do Slime ---
@export var jump_cooldown: float = 3.0   # Tempo parado
@export var jump_duration: float = 0.5   # Tempo pulando

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

	# Se estiver tomando dano, morto, ou atacando, não faz nada
	if current_state == State.HURT or \
	   current_state == State.DEAD or \
	   current_state == State.ATTACK:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# Roda a lógica do estado atual
	match current_state:
		State.IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, 100 * delta) # Freia
			animacao.play("idle_f") # (Vamos ajustar a direção depois)

		State.WANDER: # WANDER = "Pular"
			velocity = velocity.move_toward(Vector2(100, 0), 10) # Pula (direção provisória)
			animacao.play("jump_f") # (Vamos ajustar a direção depois)

	move_and_slide()


# O Timer nos avisa quando mudar de estado
func _on_jump_timer_timeout():
	if current_state == State.IDLE:
		# Estava parado? Começa a pular.
		current_state = State.WANDER
		jump_timer.start(jump_duration)
	elif current_state == State.WANDER:
		# Estava pulando? Começa a parar.
		current_state = State.IDLE
		jump_timer.start(jump_cooldown)
