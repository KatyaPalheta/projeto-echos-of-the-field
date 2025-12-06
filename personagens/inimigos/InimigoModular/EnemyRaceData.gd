extends Resource
class_name EnemyWeaponData

@export_group("Visual")
@export var texture_weapon: Texture2D # O sprite da arma (ex: Espada de Osso)

@export_group("Combate")
@export var damage: float = 10.0
@export var knockback_force: float = 300.0
@export var attack_cooldown: float = 1.5

@export_group("Animação")
# O nome da animação que deve tocar no CombatAnimationPlayer
# Ex: "melee_swing", "spear_stab", "bow_shoot"
@export var animation_name: String = "melee_swing"

@export_group("Hitbox")
# O tamanho da área de dano. X é largura (alcance), Y é altura.
@export var hitbox_size: Vector2 = Vector2(40, 40)
