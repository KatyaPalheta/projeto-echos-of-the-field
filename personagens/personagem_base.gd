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
var _ultimo_terreno: String = "grama" # <-- MUDANÇA: Para saber se trocamos de chão

# --- CONTROLE DE SOM (Loop) ---
var _passo_grama_index: int = 0 # <-- MUDANÇA: Índice para o som de grama
var _passo_areia_index: int = 0 # <-- MUDANÇA: Índice para o som de areia


# <-- MUDANÇA: Adicionamos a função _ready()
func _ready() -> void:
	# Conecta o sinal "finished" (som terminou de tocar) a uma função nossa
	audio_passos_grama.finished.connect(_on_passo_grama_finished)
	audio_passos_areia.finished.connect(_on_passo_areia_finished)


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
	
	# --- DETECÇÃO DO SOLO ---
	detector_solo.force_raycast_update() 
	
	if detector_solo.is_colliding():
		var collider = detector_solo.get_collider()
		if collider.get_collision_layer_value(2): # Camada 2 = Grama
			terreno_atual = "grama"
		elif collider.get_collision_layer_value(3): # Camada 3 = Areia
			terreno_atual = "areia"
	# --- FIM DA DETECÇÃO ---
	
	
	# --- LÓGICA DE ÁUDIO E ANIMAÇÃO (TUDO REFEITO) ---
	
	var esta_se_movendo_agora: bool = velocity.length_squared() > 0.01
	var mudou_de_terreno: bool = (terreno_atual != _ultimo_terreno)
	
	# 1. Player COMEÇOU a se mover (antes estava parado)
	if esta_se_movendo_agora and not _is_moving:
		_tocar_proximo_passo() # Toca o PRIMEIRO som da sequência
	
	# 2. Player PAROU de se mover (antes estava se movendo)
	if not esta_se_movendo_agora and _is_moving:
		audio_passos_grama.stop() # Para qualquer som que estiver tocando
		audio_passos_areia.stop()
	
	# 3. Player MUDOU DE TERRENO (enquanto ainda estava andando)
	if esta_se_movendo_agora and mudou_de_terreno:
		audio_passos_grama.stop() # Para o som antigo
		audio_passos_areia.stop()
		_tocar_proximo_passo() # Toca o primeiro som do NOVO terreno
		
	# 4. Atualiza os estados para o próximo frame
	_is_moving = esta_se_movendo_agora
	_ultimo_terreno = terreno_atual
	
	
	# --- LÓGICA DE ANIMAÇÃO (separada do áudio agora) ---
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
				_face_direction = 1
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


# --- NOSSAS NOVAS FUNÇÕES DE ÁUDIO ---

# Esta função é chamada quando o som de PASSO NA GRAMA TERMINA
func _on_passo_grama_finished() -> void:
	# Se ainda estamos andando E ainda estamos na grama, toca o próximo
	if _is_moving and terreno_atual == "grama":
		_tocar_proximo_passo()

# Esta função é chamada quando o som de PASSO NA AREIA TERMINA
func _on_passo_areia_finished() -> void:
	# Se ainda estamos andando E ainda estamos na areia, toca o próximo
	if _is_moving and terreno_atual == "areia":
		_tocar_proximo_passo()


# Esta função (que substitui a antiga _tocar_som_passo) toca o som
# da lista baseado no índice, e não mais aleatoriamente.
func _tocar_proximo_passo() -> void:
	
	if terreno_atual == "grama":
		if sons_passos_grama.is_empty(): return
		
		audio_passos_grama.stream = sons_passos_grama[_passo_grama_index]
		audio_passos_grama.pitch_scale = 1.5 # Mantém sua velocidade de 1.5x
		audio_passos_grama.play()
		
		# Avança o índice para o próximo som (e dá a volta no final da lista)
		_passo_grama_index = (_passo_grama_index + 1) % sons_passos_grama.size()
			
	elif terreno_atual == "areia":
		if sons_passos_areia.is_empty(): return
		
		audio_passos_areia.stream = sons_passos_areia[_passo_areia_index]
		audio_passos_areia.pitch_scale = 1.5 # Mantém sua velocidade de 1.5x
		audio_passos_areia.play()
		
		_passo_areia_index = (_passo_areia_index + 1) % sons_passos_areia.size()
