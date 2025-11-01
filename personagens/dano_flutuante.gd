extends Label

var dano_recebido: float = 0.0

func _ready() -> void:
	# O 'text = ...' foi removido daqui (ele agora está no setup)
	
	# Pega a posição inicial
	var pos_inicial = global_position
	# Define a posição final (ex: 32 pixels para cima)
	var pos_final = pos_inicial - Vector2(0, 32)
	
	# Cria um Tween (animador)
	var tween = create_tween()
	
	# --- O CÓDIGO QUE EU ESQUECI ESTÁ AQUI ---
	# Animação 1: Mover para cima (duração de 0.8s)
	tween.tween_property(self, "global_position", pos_final, 0.4).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	
	# Animação 2: Desaparecer (Fade out)
	# Começa o fade out nos últimos 0.3s da animação
	tween.tween_property(self, "modulate:a", 0.0, 0.3).set_delay(0.5)
	# --- FIM DO CÓDIGO QUE FALTAVA ---
	
	# Espera o Tween terminar e se autodestrói
	await tween.finished
	queue_free()

# Esta é a função que o HealthComponent vai chamar (ATUALIZADA)
func setup(dano: float, local: Vector2, cor: Color) -> void:
	dano_recebido = dano
	global_position = local
	
	# Define o texto e a cor AQUI
	text = str(int(dano_recebido))
	modulate = cor
