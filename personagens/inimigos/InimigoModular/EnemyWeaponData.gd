extends Resource
class_name EnemyWeaponData

@export_group("Visual")
@export var texture_weapon: Texture2D # O sprite da arma

@export_group("Combate")
@export var animation_name: String = "melee_swing" # Nome exato da animação no Player
@export var damage: float = 10.0
@export var hitbox_size: Vector2 = Vector2(40, 40)
