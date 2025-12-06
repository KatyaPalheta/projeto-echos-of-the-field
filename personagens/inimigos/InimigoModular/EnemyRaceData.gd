extends Resource
class_name EnemyRaceData

@export_group("Visual")
@export var texture_body: Texture2D # O corpo (sem braços)
@export var texture_hand: Texture2D # A mão (separada)

@export_group("Atributos")
@export var move_speed: float = 80.0
@export var max_health: float = 100.0
