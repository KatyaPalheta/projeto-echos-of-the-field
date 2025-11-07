# [Script: missil_de_fogo.gd]
extends Area2D

# --- Configuração da Magia ---
# (Plugue sua cena de "Impacto" aqui no Inspetor)
@export var cena_impacto_fogo: PackedScene

var direcao: Vector2 = Vector2.DOWN
var velocidade: float = 250.0  # Mais lento que a flecha (350), como vc pediu

# --- Configuração de Dano (Sua visão!) ---
var dano_imediato: float = 10.0
var dano_queimadura: float = 3.0   # 3 de dano por segundo
var duracao_queimadura: float = 5.0 # por 5 segundos

# --- Referências de Nós ---
@onready var audio_floush: AudioStreamPlayer2D = $AudioFloush
@onready var sprite: Sprite2D = $Sprite2D # (Ou o nome do seu nó de sprite)
@onready var notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

func _ready():
	# Define a rotação (igual fizemos na flecha) 
	rotation = direcao.angle()
	
	# (OPCIONAL: Gire o sprite se o seu desenho estiver "de lado")
	# sprite.rotation_degrees = 90 
	
	# (Plugue seu som "Floush" no stream do AudioFloush no editor)
	audio_floush.play() #[cite: 28]
	
	# Conecta os sinais
	body_entered.connect(_on_body_entered)
	notifier.screen_exited.connect(queue_free) 

func _physics_process(delta: float):
	# Move o projétil 
	global_position += direcao * velocidade * delta

func _on_body_entered(body: Node2D):
	
	# 1. Checa se acertou um inimigo 
	if body.is_in_group("damageable_enemy"):
		
		# --- A LÓGICA CENTRAL ---
		
		# A. Aplica o dano imediato (10)
		#    (Note o 'false' no final: SEM KNOCKBACK, como você pediu!)
		body.sofrer_dano(dano_imediato, Vector2.ZERO, false) 
		
		# B. Aplica a queimadura (Vamos criar esta função no Passo 2)
		#    (Não vai dar erro, o Godot só vai avisar que o método não existe ainda)
		body.aplicar_queimadura(dano_queimadura, duracao_queimadura)
		
		# C. Spawna o impacto visual
		_spawnar_impacto()
		
		# D. Destrói o míssil
		queue_free()

	# 2. Checa se acertou um obstáculo (ex: Árvore) 
	elif body.is_in_group("obstaculos"):
		_spawnar_impacto()
		queue_free()

# (Função idêntica à da flecha, para criar o "Impacto") 
func _spawnar_impacto():
	if cena_impacto_fogo == null:
		return
		
	var impacto = cena_impacto_fogo.instantiate()
	impacto.global_position = global_position #[cite: 29]
	impacto.rotation = rotation # (Gira o impacto junto) [cite: 30]
	get_parent().add_child(impacto)
