extends CharacterBody2D
class_name InimigoBase # <-- Muito útil para o futuro!

# --- Componentes (como no player) ---
@onready var animacao: AnimationPlayer = $Animacao
@onready var health_component: HealthComponent = $HealthComponent 

# --- Variáveis de Estado ---
# Vamos usar isso para controlar (parado, andando, atacando, morrendo)
enum State { IDLE, WANDER, CHASE, ATTACK, HURT, DEAD }
var current_state: State = State.IDLE

# --- Stats Base (cada inimigo pode mudar isso) ---
@export var move_speed: float = 50.0
@export var attack_damage: float = 10.0
@export var knockback_force: float = 120.0

func _ready():
	# Conecta o sinal de morte do HealthComponent 
	# (Todo inimigo agora pode morrer!)
	health_component.morreu.connect(_on_morte)

# --- Funções de Estado (vamos preencher depois) ---

func _physics_process(delta):
	# Aqui vai a lógica de movimento (IA)
	pass

# --- Funções de Dano e Morte ---

# Esta é a função que o player vai chamar para causar dano
func sofrer_dano(dano: float, direcao_do_ataque: Vector2):
	if current_state == State.DEAD:
		return 

	health_component.sofrer_dano(dano)

	# --- LÓGICA ATUALIZADA ---
	# Pega o sufixo da direção DE ONDE VEIO O ATAQUE
	var anim_sufixo = _get_suffix_from_direction(direcao_do_ataque)

	current_state = State.HURT
	animacao.play("hurt" + anim_sufixo) # Ex: "hurt_p"

	# (Aqui vamos adicionar a lógica de "ser jogado pra tras")


# Esta função é chamada pelo SINAL do HealthComponent
func _on_morte():
	current_state = State.DEAD

	# --- LÓGICA ATUALIZADA ---
	# Pega o sufixo da direção em que o inimigo estava olhando
	# (Vamos ter que adicionar uma var _face_direction como no player)
	# POR ENQUANTO, vamos só usar a de frente:

	animacao.play("dead_f") # <-- VAI TOCAR SÓ A "dead_f" POR ENQUANTO

	# (Aqui vamos desativar colisões e fazer ele sumir)
func _get_suffix_from_direction(direction: Vector2) -> String:
	# Se o movimento Y (vertical) for o mais forte...
	if abs(direction.y) > abs(direction.x):
		if direction.y < 0:
			return "_c" # Cima (costas)
		else:
			return "_f" # Baixo (frente)
	# Se o movimento X (horizontal) for o mais forte...
	else:
		if direction.x != 0:
			return "_p" # Perfil
		else:
			# Se não tiver direção (parado), usa a frente
			return "_f"
