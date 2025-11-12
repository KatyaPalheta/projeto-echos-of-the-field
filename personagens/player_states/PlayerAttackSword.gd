# [Script: PlayerAttackSword.gd]
extends EstadoPlayer

# Esta variável é importante! Usamos para garantir que
# só vamos para 'Idle' DEPOIS que a animação acabar.
var _ataque_terminou: bool = false
# [Em: PlayerAttackSword.gd]
# (Substitua esta função)

func enter():
	_ataque_terminou = false
	
	# 1. Toca a animação de ataque
	var anim_sufixo = "_f"
	if player._face_direction == 1: anim_sufixo = "_c"
	elif player._face_direction == 2: anim_sufixo = "_p"
	
	# 2. Define o dano (normal ou especial)
	# --- MUDANÇA AQUI ---
	# (Agora checa a variável, não mais o número "50.0")
	if player.current_attack_damage == player.dano_espada_especial:
	# --- FIM DA MUDANÇA ---
		player._animation.play("espada_duplo" + anim_sufixo)
	else:
		player._animation.play("espada" + anim_sufixo)
	
	# 3. Conecta o sinal de "animação terminada" A SI MESMO.
	player._animation.animation_finished.connect(
		_on_animation_finished, 
		CONNECT_ONE_SHOT 
	)
func exit():
	# Garante que o dano volte ao padrão
	player.current_attack_damage = 25.0

func process_physics(delta: float):
	# 1. Enquanto ataca, o player não se move
	player.velocity = Vector2.ZERO
	player.move_and_slide()
	player._update_footstep_audio() # (Para parar os sons)

	# 2. Se a animação já acabou, volta para o Idle
	if _ataque_terminou:
		state_machine._change_state(state_machine.get_node("Idle"))

# Esta função é chamada pelo SINAL que conectamos no 'enter'
func _on_animation_finished(anim_name: String):
	# Checa se a animação que acabou foi a de espada
	if anim_name.begins_with("espada_"):
		_ataque_terminou = true
