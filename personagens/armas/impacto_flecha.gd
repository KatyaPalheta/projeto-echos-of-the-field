# [Script: impacto_flecha.gd]
extends Sprite2D

# Pega a referência do nosso AnimationPlayer
@onready var anim_player: AnimationPlayer = $AnimationPlayer

func _ready():
	# Conecta o sinal de "animação terminada" do player
	# à nossa função de se autodestruir.
	anim_player.animation_finished.connect(_on_animation_finished)

# Esta função é chamada automaticamente quando a animação (que não está em loop) termina.
func _on_animation_finished(_anim_name: String):
	queue_free() # Adeus!
