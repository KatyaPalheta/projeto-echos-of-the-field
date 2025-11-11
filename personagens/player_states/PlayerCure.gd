# [Script: PlayerCure.gd]
extends EstadoPlayer

var _cura_terminou: bool = false

func enter():
	_cura_terminou = false
	
	# 1. Toca a animação de cura
	var anim_sufixo = "_f"
	if player._face_direction == 1: anim_sufixo = "_c"
	elif player._face_direction == 2: anim_sufixo = "_p"
	
	player._animation.play("magia_cura" + anim_sufixo)
	
	# 2. Conecta o sinal de "animação terminada"
	player._animation.animation_finished.connect(
		_on_animation_finished, 
		CONNECT_ONE_SHOT
	)

func process_physics(delta: float):
	# 1. Enquanto cura, o player não se move
	player.velocity = Vector2.ZERO
	player.move_and_slide()
	player._update_footstep_audio() # (Para parar os sons)

	# 2. Se a animação já acabou, volta para o Idle
	if _cura_terminou:
		state_machine._change_state(state_machine.get_node("Idle"))

# Esta função é chamada pelo SINAL
func _on_animation_finished(anim_name: String):
	if anim_name.begins_with("magia_cura_"):
		_cura_terminou = true
