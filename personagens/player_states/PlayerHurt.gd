# [Script: PlayerHurt.gd]
# (Versão com LOGS DE DEBUG)

extends EstadoPlayer

var _hurt_terminou: bool = false
var _direcao_knockback: Vector2 = Vector2.ZERO

# Função especial de setup (o 'player.gd' vai chamar isso)
func setup_knockback(direcao_do_ataque: Vector2):
	_direcao_knockback = direcao_do_ataque

func enter():
	_hurt_terminou = false
	
	# 1. Toca a animação de "hurt"
	var anim_sufixo = "_f" 
	if _direcao_knockback.y < -0.5: anim_sufixo = "_c"
	elif abs(_direcao_knockback.x) > 0.5: anim_sufixo = "_p"
	
	var anim_para_tocar = "hurt" + anim_sufixo
	player._animation.play(anim_para_tocar)
	
	# 2. Aplica a velocidade inicial do knockback
	player.velocity = _direcao_knockback * 300.0 
	
	# --- NOSSOS NOVOS LOGS ---
	Logger.log("--- HURT: Entrei no estado! ---")
	Logger.log("... Posição inicial: %s" % player.global_position)
	Logger.log("... Tocando animação: %s" % anim_para_tocar)
	Logger.log("... Velocidade inicial: %s" % player.velocity)
	# --- FIM DOS LOGS ---
	
	# 3. Conecta o sinal de "animação terminada"
	player._animation.animation_finished.connect(
		_on_animation_finished, 
		CONNECT_ONE_SHOT
	)

# Esta função é chamada pelo SINAL
func _on_animation_finished(anim_name: String):
	# --- NOSSO NOVO LOG ---
	Logger.log(">>> ANIMAÇÃO TERMINADA! Nome: %s" % anim_name)
	# --- FIM DO LOG ---

	# SÓ marca como 'terminou' se a animação correta acabou
	if anim_name.begins_with("hurt_"):
		_hurt_terminou = true

func process_physics(_delta: float):
	# --- ESTE É O "FREIO" (ATRITO) ---
	player.velocity = player.velocity.move_toward(Vector2.ZERO, 2500 * _delta)
	player.move_and_slide()
	player._update_footstep_audio() 
	
	# --- NOSSO NOVO LOG (Sua sugestão!) ---
	var direcional_pressionado = Input.get_vector("move_esquerda", "move_direita", "move_cima", "move_baixo").length() > 0.01
	Logger.log("... HURT Physics: Velocidade atual: %s (Direcional pressionado: %s)" % [player.velocity, direcional_pressionado])
	# --- FIM DO LOG ---

	# 2. Se a animação já acabou, volta para o Idle
	if _hurt_terminou:
		# --- NOSSO NOVO LOG ---
		Logger.log("--- HURT: Saindo do estado! ---")
		Logger.log("... Posição final: %s" % player.global_position)
		# --- FIM DO LOG ---
		state_machine._change_state(state_machine.get_node("Idle"))

# Vamos adicionar esta função para termos 100% de certeza
# que o input não está "vazando"
func process_input(_event: InputEvent):
	pass # Intencionalmente não faz NADA com o input
