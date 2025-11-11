# [Script: PlayerIdle.gd]
extends EstadoPlayer

# (Vamos deixar o 'enter' e 'exit' vazios por enquanto)

func process_input(event: InputEvent):
	# Se qualquer ação de movimento for pressionada, muda para o estado "Move"
	if Input.is_action_pressed("move_esquerda") or \
	   Input.is_action_pressed("move_direita") or \
	   Input.is_action_pressed("move_cima") or \
	   Input.is_action_pressed("move_baixo"):
		
		# Pede ao StateMachine para mudar o estado (passando o NOME do nó)
		state_machine._change_state(state_machine.get_node("Move"))
		return # (Importante: para de processar aqui)
# [Em: PlayerIdle.gd]
# (Substitua esta função)
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
