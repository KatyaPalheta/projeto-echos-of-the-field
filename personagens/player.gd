extends "res://personagens/personagem_base.gd"
@onready var health_component: HealthComponent = $HealthComponent
var is_in_action: bool = false

func _ready():
	
	health_component.morreu.connect(_on_morte)
	_animation.animation_finished.connect(_on_animation_finished)
	
func _on_morte():
	print("O PLAYER MORREU!")
	# Aqui no futuro vamos chamar a animação de morte,
	# parar o movimento e desabilitar colisões.
func _physics_process(delta):
	
	# Se o player está no meio de uma ação (atacando/curando),
	# ele não pode se mover e não pode começar outra ação.
	if is_in_action:
		return # Pula todo o resto da função
		
	# --- 1. Lógica de Movimento (só roda se NÃO estiver em ação) ---
	# Isso garante que o player ande (chama o personagem_base.gd)
	super(delta) 
	
	# --- 2. Lógica de Animação (vamos pegar a direção) ---
	# (player.gd herda _face_direction de personagem_base.gd)
	var anim_sufixo = "_f" # Padrão: frente
	if _face_direction == 1:
		anim_sufixo = "_c" # Costas
	elif _face_direction == 2:
		anim_sufixo = "_p" # Perfil

	# --- 3. Lógica de Ações ---
	
	# Ação de Cura (Botão B)
	if Input.is_action_just_pressed("curar"):
		is_in_action = true # TRAVA o player
		_animation.play("magia_cura" + anim_sufixo) # NOME CORRETO
		health_component.curar(25.0)
		print("Player usou CURA!")
		
	# Ação de Ataque (Botão X)
	elif Input.is_action_just_pressed("ataque_primario"):
		# Usamos "elif" para o player não poder curar e atacar no mesmo frame
		is_in_action = true # TRAVA o player
		_animation.play("espada" + anim_sufixo) # NOME CORRETO
		print("Player usou ATAQUE ESPADA!")
	# Esta função é chamada QUANDO QUALQUER ANIMAÇÃO TERMINA
func _on_animation_finished(anim_name: String):
	
	# Checa se a animação que terminou é uma de "ação"
	# (Usando os nomes que você me passou!)
	if anim_name.begins_with("espada_") or anim_name.begins_with("magia_cura_"):
		
		is_in_action = false # DESTRAVA o player
