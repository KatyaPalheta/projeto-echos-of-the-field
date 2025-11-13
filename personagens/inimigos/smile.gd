# [Script: smile.gd] (VERSÃO REATORADA FINAL)
extends InimigoBase # <-- HERDA DO NOSSO MOLDE!

@export_category("Randomização do Slime")
@export var lista_texturas: Array[Texture2D]
@export var min_jump_distance: float = 24.0
@export var attack_range: float = 10.0

# --- Variáveis do Pulo do Slime ---
@export var jump_cooldown: float = 3.0   # Tempo parado
@export var jump_duration: float = 0.5   # Tempo pulando

var chosen_jump_direction: Vector2 = Vector2.RIGHT # Guarda a direção do pulo
var directions_list: Array[Vector2] = [
	Vector2.UP, 
	Vector2.DOWN, 
	Vector2.LEFT, 
	Vector2.RIGHT
]

# NOTA: O JumpTimer deve estar na cena 'smile.tscn'
@onready var jump_timer: Timer = $JumpTimer

func _ready():
	super() # <-- IMPORTANTE: Chama o _ready() do inimigo_base

	# Sorteia qual spritesheet completo vamos usar
	if not lista_texturas.is_empty():
		# 'textura' é a var que herdamos do 'inimigo_base'!
		textura.texture = lista_texturas.pick_random()

# --- TODO O _physics_process FOI REMOVIDO! ---
# --- A função _on_jump_timer_timeout FOI REMOVIDA! ---
#
# Toda a lógica agora está nos arquivos de Estado 
# (Idle.gd, Wander.gd, Chase.gd, etc.)
