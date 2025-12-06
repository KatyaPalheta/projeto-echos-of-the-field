extends InimigoBase
class_name InimigoModular

# --- Configuração Modular ---
@export_category("Configuração Modular")
@export var raca_data: EnemyRaceData
@export var arma_data: EnemyWeaponData

# --- Referências Internas ---
@onready var visuals: Node2D = $Visuals
@onready var body_sprite: Sprite2D = $Visuals/BodySprite
@onready var weapon_pivot: Node2D = $Visuals/WeaponPivot
@onready var weapon_sprite: Sprite2D = $Visuals/WeaponPivot/WeaponSprite
@onready var hand_front: Sprite2D = $Visuals/WeaponPivot/HandFront
@onready var hand_back: Sprite2D = $Visuals/WeaponPivot/HandBack
@onready var combat_anim: AnimationPlayer = $Visuals/WeaponPivot/CombatAnimationPlayer
@onready var hitbox_col: CollisionShape2D = $Visuals/WeaponPivot/HitBox/CollisionShape2D

# Variável de controle de dano
var dano_atual: float = 0.0

func _ready() -> void:
	# Se a textura não foi linkada no inspector, tentamos pegar automaticamente
	if textura == null:
		textura = body_sprite
		
	super() # Chama o setup do InimigoBase (vida, state machine, etc)
	
	if raca_data and arma_data:
		setup_modular_character()
	else:
		push_warning("Inimigo Modular: Faltando dados de Raça ou Arma!")

func setup_modular_character() -> void:
	# 1. Configura Aparência (Raça)
	body_sprite.texture = raca_data.texture_body
	hand_front.texture = raca_data.texture_hand
	hand_back.texture = raca_data.texture_hand
	
	# Aplica stats da raça
	if health_component:
		health_component.max_health = raca_data.max_health
		health_component.health = raca_data.max_health
	move_speed = raca_data.move_speed
	
	# 2. Configura Arma
	weapon_sprite.texture = arma_data.texture_weapon
	dano_atual = arma_data.damage
	
	# Configura Hitbox
	if hitbox_col.shape is RectangleShape2D:
		hitbox_col.shape.size = arma_data.hitbox_size
		hitbox_col.position.x = arma_data.hitbox_size.x / 2

# --- Funções de Controle ---

# Sobrescrevemos ou criamos um método auxiliar para virar
func virar_para_direcao(dir_x: float):
	if dir_x > 0:
		visuals.scale.x = 1 # Direita
	elif dir_x < 0:
		visuals.scale.x = -1 # Esquerda
	
	# Atualiza a variavel do InimigoBase para compatibilidade
	if dir_x != 0:
		face_direction = Vector2(dir_x, 0)

# Função de Teste para o Playground
func testar_ataque():
	if combat_anim.has_animation(arma_data.animation_name):
		combat_anim.stop()
		combat_anim.play(arma_data.animation_name)
	else:
		print("Erro: Animação '%s' não existe no CombatAnimationPlayer!" % arma_data.animation_name)
