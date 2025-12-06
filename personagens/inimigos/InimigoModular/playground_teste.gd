extends Node2D

@onready var boneco = $InimigoModular

func _process(delta):
	# Movimento básico
	var input = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	boneco.velocity = input * 150
	boneco.move_and_slide()
	
	if input.x != 0:
		boneco.virar_para_direcao(input.x)
	
	# Ataque
	if Input.is_action_just_pressed("ui_accept"): # Espaço
		boneco.testar_ataque()
