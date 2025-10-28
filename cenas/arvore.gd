extends StaticBody2D

@onready var sprite: Sprite2D = $Textura

# Esta função será chamada pelo ComponenteDecoracao
func setup(texture: Texture2D):
	sprite.texture = texture
