extends Area2D
class_name DecoracaoRasteira

@onready var sprite: Sprite2D = $Sprite
@onready var audio_mato: AudioStreamPlayer2D = $AudioMato # <<<<< FALTAVA ISSO

var is_swaying: bool = false # Trava para não balançar sem parar

# --- NOSSOS SONS ---
@export var sons_mato: Array[AudioStream] = [
	preload("res://assets/terrain/audios/mato1.MP3"),
	preload("res://assets/terrain/audios/mato2.MP3"),
	preload("res://assets/terrain/audios/mato3.MP3")
]
# --- FIM DOS SONS ---


func _ready() -> void: # <<<<< FALTAVA ISSO
	# Conecta o sinal "body_entered" desta Area2D a si mesma
	body_entered.connect(_on_body_entered) # <<<<< FALTAVA ISSO

# Esta função será chamada para configurar a textura
# (Será chamada pelo GerenciadorDeTerreno)
func setup(texture: Texture2D, sprite_offset: Vector2):
	sprite.texture = texture
	# Usamos a mesma lógica de offset do seu script original 
	sprite.centered = false
	sprite.offset = -sprite_offset

# Esta função roda quando um Corpo Físico (como o Player) entra na área
func _on_body_entered(body: Node2D) -> void:
	# Se já estiver balançando, ou se o que entrou não for o Player, ignora
	if is_swaying or not body is PersonagemBase:
		return
		
	is_swaying = true
	
	# --- TOCA O SOM DO MATO ---
	# 1. Checa se a lista de sons não está vazia E se o player de áudio não está tocando
	if not sons_mato.is_empty() and not audio_mato.is_playing():
		# 2. Sorteia um som da lista
		audio_mato.stream = sons_mato.pick_random()
		# 3. Toca o som
		audio_mato.play()
	# --- FIM DO SOM ---
	
	# Pega a velocidade do player para saber a direção
	var player_velocity: Vector2 = body.velocity
	var sway_direction: float = 1.0
	
	# Balança na direção do movimento horizontal do player
	if player_velocity.x != 0:
		sway_direction = sign(player_velocity.x)
		
	# Cria uma animação de "peteleco"
	var tween = create_tween()
	# Inclina para o lado
	tween.tween_property(sprite, "rotation_degrees", 15.0 * sway_direction, 0.15).set_trans(Tween.TRANS_QUAD)
	# Volta para o centro (um pouco mais devagar)
	tween.tween_property(sprite, "rotation_degrees", 0.0, 0.25).set_trans(Tween.TRANS_BOUNCE)
	
	# Espera a animação terminar para poder balançar de novo
	await tween.finished
	is_swaying = false
