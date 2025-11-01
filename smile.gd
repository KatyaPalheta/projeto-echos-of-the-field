extends InimigoBase # <-- HERDA DO NOSSO MOLDE!

@export_category("Randomização do Slime")
@export var lista_texturas: Array[Texture2D]
@export var min_jump_distance: float = 24.0
@export var attack_range: float = 10.0

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
	# --- LÓGICA DE ESTADO (HURT/DEAD) ---
	if current_state == State.DEAD:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	if current_state == State.HURT:
		velocity = velocity.move_toward(Vector2.ZERO, 1500 * delta)
		move_and_slide()
		return 
	# (A checagem de ATTACK foi movida para dentro do match)

	var anim_sufixo = _get_suffix_from_direction(face_direction)

	match current_state:
		State.IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, 100 * delta)
			animacao.play("idle" + anim_sufixo)
			
		State.WANDER:
			velocity = velocity.move_toward(chosen_jump_direction * move_speed, 100 * delta) 
			animacao.play("jump" + anim_sufixo)

		State.CHASE:
			if player_target != null:
				var vector_to_player = player_target.global_position - global_position
				var distance_to_player = vector_to_player.length()

				# 1. MUDANÇA PARA O ESTADO DE ATAQUE
				if distance_to_player < attack_range:
					current_state = State.ATTACK
					velocity = Vector2.ZERO # Para de se mover
				
				# 2. LÓGICA DE PERSEGUIÇÃO "MOLENGA"
				elif distance_to_player < min_jump_distance:
					var cardinal_direction = Vector2.ZERO
					if abs(vector_to_player.x) > abs(vector_to_player.y):
						cardinal_direction = Vector2(sign(vector_to_player.x), 0)
					else:
						cardinal_direction = Vector2(0, sign(vector_to_player.y))
					
					face_direction = cardinal_direction
					anim_sufixo = _get_suffix_from_direction(face_direction)
					velocity = velocity.move_toward(cardinal_direction * (move_speed * 0.5), 100 * delta)
					animacao.play("idle" + anim_sufixo)
				
				# 3. LÓGICA DE PERSEGUIÇÃO "PULO"
				else:
					var cardinal_direction = Vector2.ZERO
					if abs(vector_to_player.x) > abs(vector_to_player.y):
						cardinal_direction = Vector2(sign(vector_to_player.x), 0)
					else:
						cardinal_direction = Vector2(0, sign(vector_to_player.y))
					
					face_direction = cardinal_direction
					anim_sufixo = _get_suffix_from_direction(face_direction)
					velocity = velocity.move_toward(cardinal_direction * move_speed, 100 * delta) 
					animacao.play("jump" + anim_sufixo)
			else:
				current_state = State.IDLE

		# --- NOSSA NOVA LÓGICA DE ATAQUE ---
		State.ATTACK:
			velocity = Vector2.ZERO # Garante que está PARADO
			
			# 1. Checa se o player FUGIU
			if player_target != null:
				var distance_to_player = (player_target.global_position - global_position).length()
				if distance_to_player > attack_range:
					current_state = State.CHASE # Volta a perseguir
			else:
				current_state = State.IDLE # Player sumiu
			
			# 2. Lógica do Cooldown
			# O timer foi herdado do inimigo_base!
			if attack_timer.is_stopped():
				# Se o timer está parado, podemos atacar!
				print("SLIME ATACOU!")
				
				# Pega a direção e toca a animação de ataque
				anim_sufixo = _get_suffix_from_direction(face_direction)
				animacao.play("ataque" + anim_sufixo) # <-- PRECISA TER ESSA ANIMAÇÃO!
				
				# Reinicia o timer (ex: 1.5 segundos de espera)
				attack_timer.start(1.5)
			
			# 3. (Opcional) Se o timer NÃO estiver parado
			else:
				# Fica parado na animação "idle" enquanto espera
				if not animacao.current_animation.begins_with("ataque_"):
					animacao.play("idle" + anim_sufixo)

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
