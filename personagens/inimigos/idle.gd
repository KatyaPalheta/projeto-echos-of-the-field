# [Script: Idle.gd]
extends EstadoInimigo

func enter():
	# Garante que o timer de pulo está parado antes de iniciá-lo
	inimigo.jump_timer.stop()
	
	# Usa a variável 'jump_cooldown' do script 'smile.gd' (o 'cerebro')
	inimigo.jump_timer.start(randf_range(0.1, cerebro.jump_cooldown))
	
	# Conecta o sinal do timer A SI MESMO
	inimigo.jump_timer.timeout.connect(
		_on_jump_timer_timeout, 
		CONNECT_ONE_SHOT
	)

func exit():
	# Se sairmos do estado (ex: por tomar dano), 
	# desconectamos o sinal para evitar bugs.
	if inimigo.jump_timer.is_connected("timeout", _on_jump_timer_timeout):
		inimigo.jump_timer.timeout.disconnect(_on_jump_timer_timeout)

func process_physics(delta: float):
	# 1. Lógica de ficar parado
	inimigo.velocity = inimigo.velocity.move_toward(Vector2.ZERO, 100 * delta)
	inimigo.move_and_slide()
	
	# 2. Atualiza a animação
	var anim_sufixo = inimigo._get_suffix_from_direction(inimigo.face_direction)
	inimigo.animacao.play("idle" + anim_sufixo)
	
	# 3. Checa se viu o player
	if inimigo.player_target != null:
		state_machine._change_state(state_machine.get_node("Chase"))
		return

# Esta função é chamada pelo SINAL do JumpTimer
func _on_jump_timer_timeout():
	# Timer acabou? Vamos passear (Wander)
	state_machine._change_state(state_machine.get_node("Wander"))
