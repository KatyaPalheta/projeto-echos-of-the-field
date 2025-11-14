# [Script: flecha.gd]
extends Area2D

# --- Nossas Variáveis ---
@export var cena_impacto: PackedScene # (Plugue a cena de impacto aqui no Inspetor!)

var direcao: Vector2 = Vector2.RIGHT
var velocidade: float = 350.0
var dano: float = 20.0 # <-- DANO ATUALIZADO!

@onready var audio_disparo = $AudioDisparo

# [Em: flecha.gd]
# (SUBSTITUA ESTA FUNÇÃO INTEIRA)

func _ready():
	# --- CORREÇÃO: APLICA O BÔNUS DE VELOCIDADE ---
	if SaveManager.dados_atuais != null:
		velocidade += SaveManager.dados_atuais.bonus_velocidade_flecha
	# --- FIM DA CORREÇÃO ---
	
	# Define a rotação da flecha (ex: 0°, 90°, 180°...)
	rotation = direcao.angle() 
	
	body_entered.connect(_on_body_entered) 
	$VisibleOnScreenNotifier2D.screen_exited.connect(queue_free) 

func _physics_process(_delta: float):
	global_position += direcao * velocidade * _delta

# --- FUNÇÃO _on_body_entered ATUALIZADA ---
func _on_body_entered(body: Node2D):
	
	# 1. Checa se acertou um inimigo
	if body.is_in_group("damageable_enemy"):
		body.sofrer_dano(dano, Vector2.ZERO)
		
		# (Se tivermos uma cena de impacto configurada, spawna ela)
		if cena_impacto != null:
			_spawnar_impacto()
		
		queue_free() # Flecha se destrói

	# 2. Checa se acertou um obstáculo (ex: Árvore)
	if body.is_in_group("obstaculos"):
		
		# (Também spawna o impacto em obstáculos)
		if cena_impacto != null:
			_spawnar_impacto()
		
		queue_free() # Flecha se destrói

# --- NOSSA NOVA FUNÇÃO HELPER ---
func _spawnar_impacto():
	# 1. Cria a cena de impacto
	var impacto = cena_impacto.instantiate()
	
	# 2. Posição: Onde a flecha está agora
	impacto.global_position = global_position
	
	# 3. Rotação: A MESMA rotação da flecha! (A MÁGICA QUE VC PEDIU)
	impacto.rotation = rotation 
	
	# 4. Adiciona ao mundo (para não sumir junto com a flecha)
	get_parent().add_child(impacto)
