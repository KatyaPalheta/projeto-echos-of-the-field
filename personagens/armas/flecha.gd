# [Script: flecha.gd]
extends Area2D

# Stats da flecha
var direcao: Vector2 = Vector2.RIGHT
var velocidade: float = 350.0 # (Ajuste a gosto)
var dano: float = 10.0

@onready var audio_disparo = $AudioDisparo

func _ready():
	# Toca o "zapt" do disparo assim que nasce
	audio_disparo.play()
	
	# Garante que o sprite da flecha olhe para onde vai
	# (Se sua flecha "deitada" aponta para a Direita, isso funciona)
	rotation = direcao.angle()
	
	# Conecta os sinais
	body_entered.connect(_on_body_entered)
	$VisibleOnScreenNotifier2D.screen_exited.connect(queue_free) # Some se sair da tela

func _physics_process(delta: float):
	# O movimento!
	global_position += direcao * velocidade * delta

func _on_body_entered(body: Node2D):
	# 1. Checa se acertou um inimigo
	if body.is_in_group("damageable_enemy"):
		
		# Chama a função de dano, mas com Vetor ZERO para não dar knockback
		body.sofrer_dano(dano, Vector2.ZERO)
		
		# (Se vc tiver um som de acerto, toque ele aqui)
		
		# Se destrói
		queue_free()

	# 2. Checa se acertou um obstáculo (ex: Árvore)
	# (Para isso funcionar, suas Árvores precisam estar no grupo "obstaculos")
	if body.is_in_group("obstaculos"):
		
		# (Toca som de "thunk" na madeira aqui)
		
		# Se destrói
		queue_free()
