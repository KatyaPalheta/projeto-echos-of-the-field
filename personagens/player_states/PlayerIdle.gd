# [Script: PlayerIdle.gd]
extends EstadoPlayer
# [Em: PlayerIdle.gd]
# (Substitua esta função)

func process_input(event: InputEvent):
	
	# --- 1. AÇÕES DE AÇÃO (Prioridade) ---
	if Input.is_action_just_pressed("ataque_primario"): # X
		# --- MUDANÇA AQUI ---
		player.current_attack_damage = player.dano_espada_base
		# --- FIM DA MUDANÇA ---
		Logger.log("Player usou ATAQUE SIMPLES!")
		state_machine._change_state(state_machine.get_node("AttackSword"))
		return

	if Input.is_action_just_pressed("ataque_especial"): # Y
		# --- MUDANÇA AQUI (CUSTO) ---
		if round(player.energia_atual) >= player.custo_ataque_especial:
			player.energia_atual -= player.custo_ataque_especial
			# --- FIM DA MUDANÇA ---
			player.emit_signal("energia_mudou", player.energia_atual, player.energia_maxima)
			# --- MUDANÇA AQUI (DANO) ---
			player.current_attack_damage = player.dano_espada_especial # Prepara o dano
			# --- FIM DA MUDANÇA ---
			Logger.log("Golpe Duplo usado!")
			state_machine._change_state(state_machine.get_node("AttackSword"))
		else:
			Logger.log("Sem energia para o Golpe Duplo!")
		return
		
	if Input.is_action_just_pressed("curar"): # B
		if player.cargas_de_cura > 0:
			player.cargas_de_cura -= 1
			player.emit_signal("cargas_cura_mudou", player.cargas_de_cura)
			# --- MUDANÇA AQUI (CURA) ---
			player.health_component.curar(player.potencia_cura_base)
			# --- FIM DA MUDANÇA ---
			Logger.log("Cura usada! Restam: %s" % player.cargas_de_cura) #[cite: 61, 62]
			state_machine._change_state(state_machine.get_node("Cure"))
		else:
			Logger.log("Sem cargas de cura!")
		return

	# --- 2. AÇÕES DE MIRA (Modificadores) ---
	# (O resto da função continua igual...)
	if Input.is_action_pressed("equip_arco"): # LT
		var aim_state = state_machine.get_node("Aim")
		aim_state.setup_mira("arco") # Configura o estado ANTES
		state_machine._change_state(aim_state)
		return
		
	if Input.is_action_pressed("equip_magia"): # RT
		var aim_state = state_machine.get_node("Aim")
		aim_state.setup_mira("magia") # Configura o estado ANTES
		state_machine._change_state(aim_state)
		return

	# --- 3. AÇÃO DE MOVIMENTO (Menor Prioridade) ---
	if Input.is_action_pressed("move_esquerda") or \
	   Input.is_action_pressed("move_direita") or \
	   Input.is_action_pressed("move_cima") or \
	   Input.is_action_pressed("move_baixo"):
		
		state_machine._change_state(state_machine.get_node("Move"))
		return
func process_physics(delta: float):
	# A lógica de "ficar parado"
	
	# 1. Zera a velocidade
	player.velocity = player.velocity.move_toward(Vector2.ZERO, 100 * delta)
	player.move_and_slide()
	
	# --- CORREÇÃO AQUI ---
	# 2. Chama a lógica de áudio DEPOIS de atualizar a velocidade
	player._update_footstep_audio()
	# --- FIM DA CORREÇÃO ---

	# 3. Atualiza a animação
	var _target_anim_name: String = "idle"
	match player._face_direction:
		0: _target_anim_name += "_f"
		1: _target_anim_name += "_c"
		2: _target_anim_name += "_p"
	
	# (Só toca a animação se não estivermos no meio de outra ação)
	if not player._animation.current_animation.begins_with("espada_") and \
	   not player._animation.current_animation.begins_with("magia_cura_") and \
	   not player._animation.current_animation.begins_with("hurt_") and \
	   not player._animation.current_animation.begins_with("morte_") and \
	   not player._animation.current_animation.begins_with("arco_disparo_") and \
	   not player._animation.current_animation.begins_with("magia_fogo_"):
		
		player._animation.play(_target_anim_name)
