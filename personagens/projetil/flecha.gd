extends Area2D

@export var impacto_scene: PackedScene # <-- ISSO ESTAVA FALTANDO

var velocidade: float = 700.0
var direcao: Vector2 = Vector2.RIGHT
var dano: float = 10.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	$VisibleOnScreenNotifier2D.screen_exited.connect(queue_free)

func _physics_process(delta: float) -> void:
	position += direcao * velocidade * delta

func _on_body_entered(body: Node2D):
	var atingiu_algo = false

	# 1. Acertou um inimigo?
	if body.is_in_group("damageable_enemy"):
		body.sofrer_dano(dano, direcao, false) 
		atingiu_algo = true

	# 2. Acertou um obstáculo?
	if body.is_in_group("obstacles"):
		atingiu_algo = true

	# 3. Se acertou QUALQUER coisa...
	if atingiu_algo:
		_criar_impacto() # <-- ISSO ESTAVA FALTANDO
		queue_free() # E a flecha some

# --- NOVA FUNÇÃO HELPER ---
func _criar_impacto():
	if impacto_scene:
		var impacto = impacto_scene.instantiate()
		get_tree().root.add_child(impacto)
		impacto.global_position = self.global_position
