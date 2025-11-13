# [Script: Flee.gd]
extends EstadoInimigo

# O inimigo_base vai chamar isso
func setup_flee(posicao_do_player: Vector2):
	inimigo.player_target = null # Para de perseguir
	
	var flee_direction = (inimigo.global_position - posicao_do_player).normalized()
	inimigo.velocity = flee_direction * (inimigo.move_speed * 1.5)

func process_physics(_delta: float):
	# Mantém a velocidade de fuga
	inimigo.velocity = inimigo.velocity.move_toward(inimigo.velocity, 10 * _delta)
	inimigo.move_and_slide()
	
	# Animação
	var anim_sufixo = inimigo._get_suffix_from_direction(inimigo.velocity)
	inimigo.animacao.play("jump" + anim_sufixo)
	
	# Para o timer de "WANDER" para não parar
	inimigo.jump_timer.stop()
