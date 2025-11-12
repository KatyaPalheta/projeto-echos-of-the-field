# [Script: Chase.gd]
extends EstadoInimigo

func process_physics(_delta: float):
	# 1. Checa se o player sumiu
	if inimigo.player_target == null:
		state_machine._change_state(state_machine.get_node("Idle"))
		return
		
	var vector_to_player = inimigo.player_target.global_position - inimigo.global_position
	var distance_to_player = vector_to_player.length()
	
	# 2. Checa se está perto o suficiente para ATACAR
	if distance_to_player < cerebro.attack_range:
		state_machine._change_state(state_machine.get_node("Attack"))
		return

	# 3. Lógica de perseguição (sem diagonal)
	var cardinal_direction = Vector2.ZERO
	if abs(vector_to_player.x) > abs(vector_to_player.y):
		cardinal_direction = Vector2(sign(vector_to_player.x), 0)
	else:
		cardinal_direction = Vector2(0, sign(vector_to_player.y))
	
	inimigo.face_direction = cardinal_direction
	var anim_sufixo = inimigo._get_suffix_from_direction(inimigo.face_direction)
	
	# 4. Decide se pula ou se "arrasta" (baseado na sua lógica original)
	if distance_to_player < cerebro.min_jump_distance:
		# Perto demais, "arrasta" devagar (idle anim)
		inimigo.velocity = inimigo.velocity.move_toward(cardinal_direction * (inimigo.move_speed * 0.5), 100 * _delta)
		inimigo.animacao.play("idle" + anim_sufixo)
	else:
		# Longe, pula rápido (jump anim)
		inimigo.velocity = inimigo.velocity.move_toward(cardinal_direction * inimigo.move_speed, 100 * _delta) 
		inimigo.animacao.play("jump" + anim_sufixo)

	inimigo.move_and_slide()
