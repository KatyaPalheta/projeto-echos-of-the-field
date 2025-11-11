# [Script: PlayerMove.gd]
extends EstadoPlayer

func process_input(event: InputEvent):
	# (Aqui virá a lógica de ataque, etc. no futuro)
	pass



func process_physics(delta: float):
	
	# 1. Chama a lógica de movimento (que agora é pública)
	var direcao_movimento = player.execute_movement_logic(delta)
	
	# --- CORREÇÃO AQUI ---
	# 2. Chama a lógica de áudio DEPOIS de atualizar a velocidade
	player._update_footstep_audio()
	# --- FIM DA CORREÇÃO ---

	# 3. Se o input parou, volta para o estado IDLE
	if direcao_movimento.length_squared() < 0.01:
		state_machine._change_state(state_machine.get_node("Idle"))
		return # Para de processar
