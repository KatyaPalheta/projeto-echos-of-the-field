# [Script: Wander.gd]
extends EstadoInimigo

func enter():
	# Sorteia a direção do pulo
	cerebro.chosen_jump_direction = cerebro.directions_list.pick_random()
	inimigo.face_direction = cerebro.chosen_jump_direction
	
	# Inicia o timer de DURAÇÃO do pulo
	inimigo.jump_timer.stop()
	inimigo.jump_timer.start(cerebro.jump_duration)
	
	# Conecta o sinal A SI MESMO
	inimigo.jump_timer.timeout.connect(
		_on_jump_timer_timeout, 
		CONNECT_ONE_SHOT
	)

func exit():
	if inimigo.jump_timer.is_connected("timeout", _on_jump_timer_timeout):
		inimigo.jump_timer.timeout.disconnect(_on_jump_timer_timeout)

func process_physics(_delta: float):
	# 1. Lógica de pular
	var target_velocity = cerebro.chosen_jump_direction * inimigo.move_speed
	inimigo.velocity = inimigo.velocity.move_toward(target_velocity, 100 * _delta)
	inimigo.move_and_slide()
	
	# 2. Animação de pulo
	var anim_sufixo = inimigo._get_suffix_from_direction(inimigo.face_direction)
	inimigo.animacao.play("jump" + anim_sufixo)
	
	# 3. Checa se viu o player (Prioridade)
	if inimigo.player_target != null:
		state_machine._change_state(state_machine.get_node("Chase"))
		return

# Esta função é chamada pelo SINAL do JumpTimer
func _on_jump_timer_timeout():
	# Duração do pulo acabou? Vamos parar (Idle)
	state_machine._change_state(state_machine.get_node("Idle"))
