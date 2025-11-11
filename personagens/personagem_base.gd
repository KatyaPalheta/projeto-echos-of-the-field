extends CharacterBody2D
class_name PersonagemBase

var _face_direction: int = 0 # 0 = Frente, 1 = Costas, 2 = Perfil
var _is_moving: bool = false 

@export_category("Variaveis")
@export var _velocidade_movimento: float = 128.0

@export_category("Objetos")
@export var _animation: AnimationPlayer 

@onready var _sprite = $textura 
@onready var _hitbox_espada = $textura/HitBoxEspada

# --- NOSSOS NÓS DE ÁUDIO ---
@onready var audio_passos_grama: AudioStreamPlayer2D = $AudioPassosGrama
@onready var audio_passos_areia: AudioStreamPlayer2D = $AudioPassosAreia
# --- O DETECTOR DE SOLO FOI REMOVIDO ---

# --- NOSSAS REFERÊNCIAS DE MAPA (NOVO!) ---
var land_layer_ref: TileMapLayer
var sand_layer_ref: TileMapLayer

# --- CONTROLE DE TERRENO ---
var terreno_atual: String = "grama" # Começa na grama por padrão
var _ultimo_terreno: String = "grama"


# --- NOVA FUNÇÃO ---
# O GerenciadorDeTerreno vai chamar isso para nos dar os mapas
func set_tilemap_refs(land_map: TileMapLayer, sand_map: TileMapLayer) -> void:
	land_layer_ref = land_map
	sand_layer_ref = sand_map

func _physics_process(_delta: float) -> void:
	# Esta função agora fica (propositalmente) vazia.
	# Os estados do player (Idle, Move) agora são
	# responsáveis por chamar a lógica de áudio.
	pass
	
func execute_movement_logic(delta: float) -> Vector2:
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
	
	if land_layer_ref == null or sand_layer_ref == null:
		pass 
	else:
		var map_coords: Vector2i = land_layer_ref.local_to_map(global_position)
		if sand_layer_ref.get_cell_source_id(map_coords) != -1:
			terreno_atual = "areia"
		elif land_layer_ref.get_cell_source_id(map_coords) != -1:
			terreno_atual = "grama"
	
	# --- A LINHA ABAIXO FOI REMOVIDA DAQUI! ---
	# _is_moving = velocity.length_squared() > 0.01 
	
	if velocity.length_squared() > 0.01: # (Usamos a checagem direta)
		var _abs_vel_x = abs(velocity.x)
		var _abs_vel_y = abs(velocity.y)
		
		if _abs_vel_x > _abs_vel_y and _abs_vel_x > 0.01:
			_face_direction = 2 
			if velocity.x < 0:
				_sprite.flip_h = true 
				_hitbox_espada.scale.x = -1
			else:
				_sprite.flip_h = false 
				_hitbox_espada.scale.x = 1
		elif _abs_vel_y > _abs_vel_x and _abs_vel_y > 0.01:
			_sprite.flip_h = false 
			_hitbox_espada.scale.x = 1
			if velocity.y > 0:
				_face_direction = 0 
			else:
				_face_direction = 1
		elif _abs_vel_x > 0.01 and _abs_vel_y > 0.01 and _abs_vel_x == _abs_vel_y:
			_sprite.flip_h = false 
			if velocity.y > 0:
				_face_direction = 0
			else:
				_face_direction = 1
					
	var _target_anim_name: String = ""
	
	if velocity.length_squared() > 0.01: # (Usamos a checagem direta)
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
	
	
	if _animation.current_animation != _target_anim_name and \
	   not _animation.current_animation.begins_with("espada_") and \
	   not _animation.current_animation.begins_with("magia_cura_") and \
	   not _animation.current_animation.begins_with("hurt_") and \
	   not _animation.current_animation.begins_with("morte_") and \
	   not _animation.current_animation.begins_with("arco_disparo_") and \
	   not _animation.current_animation.begins_with("magia_fogo_"):
		
		_animation.play(_target_anim_name)
	
	return _direcao

func _update_footstep_audio():
	# Esta lógica precisa rodar independente do movimento
	var esta_se_movendo_agora: bool = velocity.length_squared() > 0.01
	var mudou_de_terreno: bool = (terreno_atual != _ultimo_terreno)
	
	if esta_se_movendo_agora and not _is_moving:
		_tocar_som_loop(terreno_atual)
	
	if not esta_se_movendo_agora and _is_moving:
		audio_passos_grama.stop()
		audio_passos_areia.stop()
	
	if esta_se_movendo_agora and mudou_de_terreno:
		audio_passos_grama.stop() 
		audio_passos_areia.stop()
		_tocar_som_loop(terreno_atual)
		
	#_is_moving = esta_se_movendo_agora (movido para execute_movement_logic)
	_is_moving = esta_se_movendo_agora
	_ultimo_terreno = terreno_atual

func _tocar_som_loop(tipo_terreno: String) -> void:
	if tipo_terreno == "grama":
		audio_passos_grama.play()
	elif tipo_terreno == "areia":
		audio_passos_areia.play()
