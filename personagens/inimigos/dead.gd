# [Script: Dead.gd]
extends EstadoInimigo

func enter():
	inimigo.animacao.play("dead" + inimigo._get_suffix_from_direction(inimigo.face_direction))
	
	# Para qualquer efeito de fogo
	inimigo._parar_queimadura()
	
	# Avisa ao GameManager
	GameManager.registrar_morte_inimigo()
	
	# Conecta o sinal de animação terminada
	inimigo.animacao.animation_finished.connect(
		_on_animation_finished, 
		CONNECT_ONE_SHOT
	)

func process_physics(_delta: float):
	# Morto não se mexe
	inimigo.velocity = Vector2.ZERO
	inimigo.move_and_slide()

# Chamado pelo sinal
func _on_animation_finished(anim_name: String):
	if anim_name.begins_with("dead_"):
		Logger.log("Slime morreu e foi removido.")
		inimigo.queue_free() # Adeus!
