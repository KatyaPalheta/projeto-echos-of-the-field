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


# [Em: PlayerAim.gd]
# (Substitua esta função)

func exit():
	# 1. Limpa tudo ao sair da mira (como antes)
	player.audio_arco_puxar.stop()
	player.audio_cast_magia.stop()
	player.mira_sprite.visible = false
	player.alvo_travado = null

	# --- NOSSA CORREÇÃO ---
	# 2. Força a volta para a animação "idle".
	#    Isso "libera" a trava de animação, impedindo
	#    que a animação "magia_fogo" ou "arco_mira"
	#    fique presa na tela.
	var _target_anim_name: String = "idle"
	match player._face_direction:
		0: _target_anim_name += "_f"
		1: _target_anim_name += "_c"
		2: _target_anim_name += "_p"
	
	# (Não precisamos checar 'begins_with' aqui, 
	#  porque *queremos* sobrescrever a animação de mira)
	player._animation.play(_target_anim_name)
	# --- FIM DA CORREÇÃO ---

@warning_ignore("unused_parameter")

# [Em: PlayerAim.gd]
# (Substitua esta função)

func process_input(_event: InputEvent):
	# Esta é a lógica de DISPARO
	
	var anim_sufixo = "_f"
	if player._face_direction == 1: anim_sufixo = "_c"
	elif player._face_direction == 2: anim_sufixo = "_p"
	
	if _tipo_mira == "arco":
		# --- AÇÕES DE ARCO (LT + X / Y) ---
		
		if Input.is_action_just_pressed("ataque_primario"): # LT + X
			if player.arco_cooldown_timer.is_stopped():
				player.arco_cooldown_timer.start(player.cadencia_arco_base) 
				player._animation.play("arco_disparo" + anim_sufixo) 
				player._disparar_flecha(anim_sufixo) 
				Logger.log("Player usou ARCO SIMPLES!")
			
		elif Input.is_action_just_pressed("ataque_especial"): # LT + Y
			# --- MUDANÇA AQUI ---
			if round(player.energia_atual) >= player.custo_ataque_especial:
				player.energia_atual -= player.custo_ataque_especial
			# --- FIM DA MUDANÇA ---
				player.emit_signal("energia_mudou", player.energia_atual, player.energia_maxima)
				player._animation.play("arco_disparo" + anim_sufixo)
				player._disparar_rajada_de_flechas(anim_sufixo)
				Logger.log("Player usou RAJADA DE FLECHAS!")
			else:
				Logger.log("Sem energia para a Rajada de Flechas!")
	
	else: # "magia"
		# --- AÇÕES DE MAGIA (RT + X / Y) ---
		
		if Input.is_action_just_pressed("ataque_primario"): # RT + X
			if player.magia_cooldown_timer.is_stopped():
				player.magia_cooldown_timer.start(player.cadencia_magia_base)
				player._animation.play("magia_fogo" + anim_sufixo)
				player._disparar_missil(anim_sufixo) 
				Logger.log("Player usou MÍSSIL DE FOGO!")
			
		elif Input.is_action_just_pressed("ataque_especial"): # RT + Y
			# --- MUDANÇA AQUI ---
			if round(player.energia_atual) >= player.custo_ataque_especial:
				player.energia_atual -= player.custo_ataque_especial
			# --- FIM DA MUDANÇA ---
				player.emit_signal("energia_mudou", player.energia_atual, player.energia_maxima)
				player._animation.play("magia_fogo" + anim_sufixo)
				player._disparar_leque_de_misseis(anim_sufixo)
				Logger.log("Player usou LEQUE DE FOGO!")
			else:
				Logger.log("Sem energia para o Leque de Fogo!")
@warning_ignore("unused_parameter")
func process_physics(_delta: float):
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
