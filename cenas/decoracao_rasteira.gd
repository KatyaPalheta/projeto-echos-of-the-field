extends Area2D
class_name DecoracaoRasteira

@onready var sprite: Sprite2D = $Sprite
var is_swaying: bool = false # Trava para não balançar sem parar

func _ready() -> void:
	# Conecta o sinal "body_entered" desta Area2D a si mesma
	body_entered.connect(_on_body_entered)

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
	
	# Pega a velocidade do player  para saber a direção
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
