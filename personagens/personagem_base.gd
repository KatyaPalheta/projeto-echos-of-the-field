extends CharacterBody2D
class_name PersonagemBase

var _face_direction: int = 0 # 0 = Frente, 1 = Costas, 2 = Perfil
var _is_moving: bool = false 

@export_category("Variaveis")
@export var _velocidade_movimento: float = 128.0

@export_category("Objetos")
@export var _animation: AnimationPlayer

@onready var _sprite = $textura 

# --- NOSSOS NÓS DE ÁUDIO ---
@onready var audio_passos_grama: AudioStreamPlayer2D = $AudioPassosGrama
@onready var audio_passos_areia: AudioStreamPlayer2D = $AudioPassosAreia
@onready var detector_solo: RayCast2D = $DetectorDeSolo

# --- NOSSAS LISTAS DE SONS DE PASSOS ---
@export var sons_passos_grama: Array[AudioStream] = [
	preload("res://assets/terrain/audios/passos1.MP3"),
	preload("res://assets/terrain/audios/passos2.MP3"),
	preload("res://assets/terrain/audios/passos3.MP3")
]
@export var sons_passos_areia: Array[AudioStream] = [
	preload("res://assets/terrain/audios/sand1.MP3"),
	preload("res://assets/terrain/audios/sand2.MP3"),
	preload("res://assets/terrain/audios/sand3.MP3")
]

# --- CONTROLE DE TERRENO ---
var terreno_atual: String = "grama" # Começa na grama por padrão

func _physics_process(_delta: float) -> void:
	
	var _direcao: Vector2 = Input.get_vector(
		"move_esquerda", "move_direita", "move_cima", "move_baixo"
	)
	
	if _direcao.length_squared() > 0.01:
		if abs(_direcao.x) > 0.01 and abs(_direcao.y) > 0.01:
			
			if abs(_direcao.x) > abs(_direcao.y):
				_direcao.y = 0
			else:
				_direcao.x = 0
			
			_direcao = _direcao.normalized()
	
	velocity = _direcao * _velocidade_movimento
	move_and_slide()
	# ... (código do move_and_slide)
	velocity = _direcao * _velocidade_movimento
	move_and_slide()
	
	# --- DETECÇÃO DO SOLO ---
	# Força o RayCast a checar o que tem embaixo dele NESTE frame
	detector_solo.force_raycast_update() 
	
	if detector_solo.is_colliding():
		var collider = detector_solo.get_collider()
		
		# Checa em qual CAMADA DE FÍSICA o colisor está
		if collider.get_collision_layer_value(2): # Camada 2 = Grama
			terreno_atual = "grama"
		elif collider.get_collision_layer_value(3): # Camada 3 = Areia
			terreno_atual = "areia"
	# --- FIM DA DETECÇÃO ---
	
	_is_moving = velocity.length_squared() > 0.01
	# ... (resto do código de animação)
	
	_is_moving = velocity.length_squared() > 0.01

	if _is_moving:

		var _abs_vel_x = abs(velocity.x)
		var _abs_vel_y = abs(velocity.y)
		
		if _abs_vel_x > _abs_vel_y and _abs_vel_x > 0.01:
			_face_direction = 2 
			
			if velocity.x < 0:
				_sprite.flip_h = true 
			else:
				_sprite.flip_h = false 
		
		elif _abs_vel_y > _abs_vel_x and _abs_vel_y > 0.01:
			_sprite.flip_h = false 
			
			if velocity.y > 0:
				_face_direction = 0 
			else:
				_face_direction = 1 #
		elif _abs_vel_x > 0.01 and _abs_vel_y > 0.01 and _abs_vel_x == _abs_vel_y:
			_sprite.flip_h = false 
			if velocity.y > 0:
				_face_direction = 0 #frente
			else:
				_face_direction = 1 #costas
					
	
	var _target_anim_name: String = ""
	
	if _is_moving:
		_target_anim_name = "run"
	else:
		_target_anim_name = "idle"
		
	match _face_direction:
		0: 
			_target_anim_name += "_f"
		1: 
			_target_anim_name += "_c"
		2: 
			_target_anim_name += "_p"
	
	if _animation.current_animation != _target_anim_name:
		_animation.play(_target_anim_name)
		# ... (fim da função _physics_process) ...


# ESTA FUNÇÃO SERÁ CHAMADA PELA ANIMATION PLAYER
func _tocar_som_passo() -> void:
	
	# Se não estiver se movendo, não toca som
	if not _is_moving:
		return

	# Decide qual som tocar baseado no terreno
	if terreno_atual == "grama":
		# Se a lista não estiver vazia E o áudio não estiver tocando
		if not sons_passos_grama.is_empty() and not audio_passos_grama.is_playing():
			audio_passos_grama.stream = sons_passos_grama.pick_random()
			audio_passos_grama.play()
			
	elif terreno_atual == "areia":
		if not sons_passos_areia.is_empty() and not audio_passos_areia.is_playing():
			audio_passos_areia.stream = sons_passos_areia.pick_random()
			audio_passos_areia.play()

# <<< FIM DO SCRIPT >>>
