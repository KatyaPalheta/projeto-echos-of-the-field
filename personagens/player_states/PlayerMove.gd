# [Script: PlayerMove.gd]
extends EstadoPlayer

# [Em: PlayerMove.gd]
# (SUBSTITUA ESTA FUNÇÃO process_input INTEIRA)

func process_input(_event: InputEvent):
	
	# --- NOVO: PEGA O MULTIPLICADOR GERAL DE DANO DO PLAYER ---
	var mult_dano_player = ConfigManager.get_gameplay_value("multiplicador_dano_espada")
	if mult_dano_player == null:
		# Fallback para 1.0 se o ConfigManager falhar
		mult_dano_player = 1.0 
	# --- FIM NOVO ---
	
	# --- 1. AÇÕES DE AÇÃO (Prioridade) ---
	if Input.is_action_just_pressed("ataque_primario"): # X
		
		# Dano Simples de Espada (Aplica Multiplicador de Dificuldade + Bônus do Upgrade)
		var bonus_dano = 0.0
		if SaveManager.dados_atuais != null:
			bonus_dano = SaveManager.dados_atuais.bonus_dano_espada
		
		# CÁLCULO FINAL: (Dano Base * Multiplicador Dificuldade) + Bônus de Upgrade
		player.current_attack_damage = (player.dano_espada_base * mult_dano_player) + bonus_dano
		
		Logger.log("Player usou ATAQUE SIMPLES!")
		state_machine._change_state(state_machine.get_node("AttackSword"))
		return

	if Input.is_action_just_pressed("ataque_especial"): # Y
		
		# --- LÓGICA DE CUSTO CORRIGIDA ---
		var bonus_reducao = 0.0
		if SaveManager.dados_atuais != null:
			bonus_reducao = SaveManager.dados_atuais.bonus_eficiencia_energia
		
		var custo_final = max(0.0, player.custo_ataque_especial - bonus_reducao)
		# --- FIM DA LÓGICA ---

		if round(player.energia_atual) >= custo_final:
			player.energia_atual -= custo_final
			player.emit_signal("energia_mudou", player.energia_atual, player.energia_maxima)
			
			# Dano Especial de Espada (Aplica Multiplicador de Dificuldade + Bônus do Upgrade)
			var bonus_dano_especial = 0.0
			if SaveManager.dados_atuais != null:
				bonus_dano_especial = SaveManager.dados_atuais.bonus_dano_espada_especial
				
			# CÁLCULO FINAL: (Dano Especial Base * Multiplicador Dificuldade) + Bônus de Upgrade
			player.current_attack_damage = (player.dano_espada_especial * mult_dano_player) + bonus_dano_especial
			
			Logger.log("Golpe Duplo usado! Custo: %s" % custo_final)
			state_machine._change_state(state_machine.get_node("AttackSword"))
		else:
			Logger.log("Sem energia para o Golpe Duplo! (Custo: %s)" % custo_final)
		return
		
	if Input.is_action_just_pressed("curar"): # B
		if player.cargas_de_cura > 0:
			player.cargas_de_cura -= 1
			player.emit_signal("cargas_cura_mudou", player.cargas_de_cura)
			
			var bonus_cura = 0.0
			if SaveManager.dados_atuais != null:
				bonus_cura = SaveManager.dados_atuais.bonus_potencia_cura
				
			var potencia_final = player.potencia_cura_base + bonus_cura
			player.health_component.curar(potencia_final)
			
			Logger.log("Cura usada! Restam: %s" % player.cargas_de_cura) 
			state_machine._change_state(state_machine.get_node("Cure"))
		else:
			Logger.log("Sem cargas de cura!")
		return

	# --- 2. AÇÕES DE MIRA (Modificadores) ---
	if Input.is_action_pressed("equip_arco"): # LT
		var aim_state = state_machine.get_node("Aim")
		aim_state.setup_mira("arco") 
		state_machine._change_state(aim_state)
		return
		
	if Input.is_action_pressed("equip_magia"): # RT
		var aim_state = state_machine.get_node("Aim")
		aim_state.setup_mira("magia") 
		state_machine._change_state(aim_state)
		return

func process_physics(_delta: float):
	
	# 1. Chama a lógica de movimento (que agora é pública)
	var direcao_movimento = player.execute_movement_logic(_delta)
	
	# --- CORREÇÃO AQUI ---
	# 2. Chama a lógica de áudio DEPOIS de atualizar a velocidade
	player._update_footstep_audio()
	# --- FIM DA CORREÇÃO ---

	# 3. Se o input parou, volta para o estado IDLE
	if direcao_movimento.length_squared() < 0.01:
		state_machine._change_state(state_machine.get_node("Idle"))
		return # Para de processar
