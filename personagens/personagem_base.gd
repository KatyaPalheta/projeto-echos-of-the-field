extends CharacterBody2D
class_name PersonagemBase

var _face_direction: int = 0 # 0 = Frente, 1 = Costas, 2 = Perfil
var _is_moving: bool = false 

@export_category("Variaveis")
@export var _velocidade_movimento: float = 128.0

@export_category("Objetos")
@export var _animation: AnimationPlayer

@onready var _sprite = $textura 

func _physics_process(_delta: float) -> void:
	
	var _direcao: Vector2 = Input.get_vector(
		"move_esquerda", "move_direita", "move_cima", "move_baixo"
	)
	
	# === 1. MOVIMENTAÇÃO ===
	velocity = _direcao * _velocidade_movimento
	move_and_slide()
	
	_is_moving = velocity.length_squared() > 0.01
	
	# === 2. DETERMINAÇÃO DA DIREÇÃO DE VISUALIZAÇÃO (EIXOS) E FLIP ===
	if _is_moving:
		# Verifica qual eixo tem o movimento mais forte
		var _abs_vel_x = abs(velocity.x)
		var _abs_vel_y = abs(velocity.y)
		
		if _abs_vel_x > _abs_vel_y and _abs_vel_x > 0.01:
			# Movimento horizontal é predominante
			_face_direction = 2 # Perfil
			
			if velocity.x < 0:
				_sprite.flip_h = true  # Vira para a esquerda
			else:
				_sprite.flip_h = false # Não vira (olha para a direita)
		
		elif _abs_vel_y > _abs_vel_x and _abs_vel_y > 0.01:
			# Movimento vertical é predominante
			_sprite.flip_h = false # Garante que o sprite não esteja invertido ao mover verticalmente
			
			if velocity.y > 0:
				_face_direction = 0 # Frente (Baixo)
			else:
				_face_direction = 1 # Costas (Cima)
		
		# === [ADICIONADO] Lógica para quando o movimento é puramente diagonal ===
		# Se os movimentos em X e Y são igualmente fortes (diagonal), priorizamos o Y para manter a frente/costas
		elif _abs_vel_x > 0.01 and _abs_vel_y > 0.01 and _abs_vel_x == _abs_vel_y:
			_sprite.flip_h = false # Garante que não esteja invertido
			if velocity.y > 0:
				_face_direction = 0 # Frente
			else:
				_face_direction = 1 # Costas
		# Fim do [ADICIONADO]
			
	# === 3. CONTROLE DAS ANIMAÇÕES ===
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
