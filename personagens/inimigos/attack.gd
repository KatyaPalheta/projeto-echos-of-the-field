# [Script: Attack.gd]
extends EstadoInimigo

func enter():
	# Para de se mover
	inimigo.velocity = Vector2.ZERO
	
	# Só ataca se o timer de ataque (do inimigo_base) estiver parado
	if inimigo.attack_timer.is_stopped():
		inimigo.attack_timer.start(1.5) # (A cadência de 1.5s)
		
		var anim_sufixo = inimigo._get_suffix_from_direction(inimigo.face_direction)
		inimigo.animacao.play("ataque" + anim_sufixo)
		
		# Conecta o sinal de "animação terminou" A SI MESMO
		inimigo.animacao.animation_finished.connect(
			_on_animation_finished, 
			CONNECT_ONE_SHOT
		)
	else:
		# Se o timer não estiver pronto, volta para o Chase
		state_machine._change_state(state_machine.get_node("Chase"))

func exit():
	if inimigo.animacao.is_connected("animation_finished", _on_animation_finished):
		inimigo.animacao.animation_finished.disconnect(_on_animation_finished)

func process_physics(_delta: float):
	# 1. Garante que está parado
	inimigo.velocity = Vector2.ZERO
	inimigo.move_and_slide()
	
	# 2. Se o player fugiu, volta pro Chase (mesmo que a animação não tenha acabado)
	if inimigo.player_target != null:
		var dist = (inimigo.player_target.global_position - inimigo.global_position).length()
		if dist > cerebro.attack_range:
			state_machine._change_state(state_machine.get_node("Chase"))
	else:
		# Player sumiu
		state_machine._change_state(state_machine.get_node("Idle"))

# Chamado pelo sinal
func _on_animation_finished(anim_name: String):
	if anim_name.begins_with("ataque_"):
		# Ataque terminou? Volta a perseguir
		state_machine._change_state(state_machine.get_node("Chase"))
