# [Script: PlayerAttackSword.gd]
extends EstadoPlayer

# Esta variável é importante! Usamos para garantir que
# só vamos para 'Idle' DEPOIS que a animação acabar.
var _ataque_terminou: bool = false

func enter():
	_ataque_terminou = false
	
	# 1. Toca a animação de ataque
	# (Usamos a 'face_direction' que já existe no 'player')
	var anim_sufixo = "_f"
	if player._face_direction == 1: anim_sufixo = "_c"
	elif player._face_direction == 2: anim_sufixo = "_p"
	
	# 2. Define o dano (normal ou especial)
	# (Usamos 'current_attack_damage' do player)
	if player.current_attack_damage == 50.0:
		player._animation.play("espada_duplo" + anim_sufixo)
	else:
		player._animation.play("espada" + anim_sufixo)
	
	# 3. Conecta o sinal de "animação terminada" A SI MESMO.
	#    Quando a animação no 'player' acabar, ela chama
	#    a função '_on_animation_finished' DESTE SCRIPT.
	# (Usamos CONNECT_ONE_SHOT para o sinal se desconectar sozinho)
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
