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
	
	# --- DETECÇÃO DO SOLO (MÉTODO NOVO: Por Coordenadas de Tile) ---
	# Checa se o Gerenciador já nos deu as referências
	if land_layer_ref == null or sand_layer_ref == null:
		# Se ainda não deu, não faz nada
		pass 
	else:
		# 1. Converte a posição GLOBAL do player para uma coordenada de TILE
		var map_coords: Vector2i = land_layer_ref.local_to_map(global_position)
		
		# 2. Checa AREIA primeiro (porque ela desenha por cima da grama [cite: 17])
		# get_cell_source_id() retorna -1 se não houver NENHUM tile ali
		if sand_layer_ref.get_cell_source_id(map_coords) != -1:
			terreno_atual = "areia"
		# 3. Se não for areia, checa GRAMA
		elif land_layer_ref.get_cell_source_id(map_coords) != -1:
			terreno_atual = "grama"
		# 4. (Opcional) Se não for nenhum dos dois (ex: água), o terreno_atual
		#    continua sendo o último que era (grama ou areia).
			
	# --- FIM DA DETECÇÃO ---
	
	
	# --- LÓGICA DE ÁUDIO E ANIMAÇÃO (Exatamente como antes) ---
	var esta_se_movendo_agora: bool = velocity.length_squared() > 0.01
	var mudou_de_terreno: bool = (terreno_atual != _ultimo_terreno)
	
	# 1. Player COMEÇOU a se mover
	if esta_se_movendo_agora and not _is_moving:
		_tocar_som_loop(terreno_atual)
	
	# 2. Player PAROU
	if not esta_se_movendo_agora and _is_moving:
		audio_passos_grama.stop()
		audio_passos_areia.stop()
	
	# 3. Player MUDOU DE TERRENO
	if esta_se_movendo_agora and mudou_de_terreno:
		audio_passos_grama.stop() 
		audio_passos_areia.stop()
		_tocar_som_loop(terreno_atual)
		
	# 4. Atualiza os estados
	_is_moving = esta_se_movendo_agora
	_ultimo_terreno = terreno_atual
	
	
	# --- LÓGICA DE ANIMAÇÃO (Exatamente como antes) ---
	if _is_moving:
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
	
	# Esta checagem agora impede o "idle" de interromper uma "ação"
	if _animation.current_animation != _target_anim_name and \
	   not _animation.current_animation.begins_with("espada_") and \
	   not _animation.current_animation.begins_with("magia_cura_") and \
	   not _animation.current_animation.begins_with("hurt_") and \
	   not _animation.current_animation.begins_with("morte_"):
		
		_animation.play(_target_anim_name)

# --- FUNÇÃO DE ÁUDIO (Exatamente como antes) ---
func _tocar_som_loop(tipo_terreno: String) -> void:
	if tipo_terreno == "grama":
		audio_passos_grama.play()
	elif tipo_terreno == "areia":
		audio_passos_areia.play()
