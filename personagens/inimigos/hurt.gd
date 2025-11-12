# [Script: Hurt.gd]
extends EstadoInimigo

# Esta é uma função especial que o inimigo_base vai chamar
# ANTES de mudar para este estado.
func setup_knockback(direcao_do_ataque: Vector2):
	var anim_sufixo = inimigo._get_suffix_from_direction(direcao_do_ataque)
	inimigo.animacao.play("hurt" + anim_sufixo)
	
	if direcao_do_ataque != Vector2.ZERO:
		inimigo.velocity = direcao_do_ataque * inimigo.knockback_force
	else:
		inimigo.velocity = Vector2.ZERO
		
	# Conecta o sinal de animação terminada
	inimigo.animacao.animation_finished.connect(
		_on_animation_finished, 
		CONNECT_ONE_SHOT
	)

func exit():
	if inimigo.animacao.is_connected("animation_finished", _on_animation_finished):
		inimigo.animacao.animation_finished.disconnect(_on_animation_finished)

func process_physics(_delta: float):
	# Lógica de "freio" do knockback
	inimigo.velocity = inimigo.velocity.move_toward(Vector2.ZERO, 1500 * _delta)
	inimigo.move_and_slide()

# Chamado pelo sinal
func _on_animation_finished(anim_name: String):
	if anim_name.begins_with("hurt_"):
		# Animação de dor acabou?
		# Checa se o player ainda está por perto
		if inimigo.player_target != null:
			state_machine._change_state(state_machine.get_node("Chase"))
		else:
			state_machine._change_state(state_machine.get_node("Idle"))
