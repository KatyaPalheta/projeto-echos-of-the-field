# [Script: PlayerAim.gd]
extends EstadoPlayer

# Vamos guardar qual 'equip' (arco ou magia) nos trouxe aqui
var _tipo_mira: String = "arco" 

# Esta é uma função especial que o StateMachine *não tem*.
# Nossos estados Idle/Move vão chamar ela para "configurar" a mira
# ANTES de mudar para este estado.
func setup_mira(tipo: String = "arco"):
	_tipo_mira = tipo

func enter():
	# 1. Toca os sons e animações iniciais
	if _tipo_mira == "arco":
		player.audio_arco_puxar.play()
		# (A animação "arco_mira" será tocada no physics)
	else: # "magia"
		player.audio_cast_magia.play()
		# (A animação "magia_fogo" será tocada no physics)
	
	# 2. Reseta a mira
	player.alvo_travado = null
	player.mira_sprite.visible = false

func exit():
	# 1. Limpa tudo ao sair da mira
	player.audio_arco_puxar.stop()
	player.audio_cast_magia.stop()
	player.mira_sprite.visible = false
	player.alvo_travado = null

# [Em: PlayerAim.gd]
# (Substitua esta função inteira)

@warning_ignore("unused_parameter")

# [Em: PlayerAim.gd]
# (Substitua esta função inteira)

func process_input(event: InputEvent):
	# Esta é a lógica de DISPARO
	
	# Pega a direção (só para o nome da animação)
	var anim_sufixo = "_f"
	if player._face_direction == 1: anim_sufixo = "_c"
	elif player._face_direction == 2: anim_sufixo = "_p"
	
	if _tipo_mira == "arco":
		# --- AÇÕES DE ARCO (LT + X / Y) ---
		
		if Input.is_action_just_pressed("ataque_primario"): # LT + X
			
			# SÓ dispara SE o timer estiver PARADO
			if player.arco_cooldown_timer.is_stopped():
				
				# --- MUDANÇA AQUI ---
				# 1. Inicia o cooldown (LENDO A VARIÁVEL DO PLAYER)
				player.arco_cooldown_timer.start(player.cadencia_arco_base) 
				# --- FIM DA MUDANÇA ---
				
				# 2. Faz o disparo (como antes)
				player._animation.play("arco_disparo" + anim_sufixo) 
				player._disparar_flecha(anim_sufixo) 
				Logger.log("Player usou ARCO SIMPLES!")
			
		elif Input.is_action_just_pressed("ataque_especial"): # LT + Y
			if round(player.energia_atual) >= player.custo_golpe_duplo:
				player.energia_atual -= player.custo_golpe_duplo
				player.emit_signal("energia_mudou", player.energia_atual, player.energia_maxima)
				player._animation.play("arco_disparo" + anim_sufixo)
				player._disparar_rajada_de_flechas(anim_sufixo)
				Logger.log("Player usou RAJADA DE FLECHAS!")
			else:
				Logger.log("Sem energia para a Rajada de Flechas!")
	
	else: # "magia"
		# --- AÇÕES DE MAGIA (RT + X / Y) ---
		
		# --- GRANDE MUDANÇA AQUI ---
		if Input.is_action_just_pressed("ataque_primario"): # RT + X
			
			# SÓ dispara SE o timer NOVO estiver PARADO
			if player.magia_cooldown_timer.is_stopped():
				
				# 1. Inicia o cooldown (usando a nova variável)
				player.magia_cooldown_timer.start(player.cadencia_magia_base)
				
				# 2. Faz o disparo (como antes)
				player._animation.play("magia_fogo" + anim_sufixo)
				player._disparar_missil(anim_sufixo) 
				Logger.log("Player usou MÍSSIL DE FOGO!")
			
			# (Se o timer não estiver parado, não faz nada)
		# --- FIM DA GRANDE MUDANÇA ---
			
		elif Input.is_action_just_pressed("ataque_especial"): # RT + Y
			if round(player.energia_atual) >= player.custo_golpe_duplo:
				player.energia_atual -= player.custo_golpe_duplo
				player.emit_signal("energia_mudou", player.energia_atual, player.energia_maxima)
				player._animation.play("magia_fogo" + anim_sufixo)
				player._disparar_leque_de_misseis(anim_sufixo)
				Logger.log("Player usou LEQUE DE FOGO!")
			else:
				Logger.log("Sem energia para o Leque de Fogo!")

@warning_ignore("unused_parameter")
func process_physics(delta: float):
	# 1. Checa se o player SOLTOU o botão de mira
	var mira_pressionada = Input.is_action_pressed("equip_arco") if _tipo_mira == "arco" else Input.is_action_pressed("equip_magia")
	
	if not mira_pressionada:
		# Se soltou, voltamos ao Idle
		state_machine._change_state(state_machine.get_node("Idle"))
		return

	# 2. Lógica de ficar parado
	player.velocity = Vector2.ZERO
	player.move_and_slide()
	player._update_footstep_audio() # (Para parar os sons)

	# 3. Lógica de atualizar mira (HUD e Alvo)
	var anim_sufixo = "_f"
	if player._face_direction == 1: anim_sufixo = "_c"
	elif player._face_direction == 2: anim_sufixo = "_p"
	
	player._atualizar_alvo_com_cone(anim_sufixo)
	
	if player.alvo_travado != null:
		player.mira_sprite.visible = true
		player.mira_sprite.global_position = player.alvo_travado.global_position
	else:
		player.mira_sprite.visible = false
	
	# 4. Toca a animação de "mirar" (se não estivermos atacando)
	var anim_base = "arco_mira" if _tipo_mira == "arco" else "magia_fogo"
	var anim_ataque = "arco_disparo" if _tipo_mira == "arco" else "magia_fogo"
	
	if not player._animation.current_animation.begins_with(anim_ataque):
		player._animation.play(anim_base + anim_sufixo)
