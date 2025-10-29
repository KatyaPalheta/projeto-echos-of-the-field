extends "res://personagens/personagem_base.gd"
@onready var health_component: HealthComponent = $HealthComponent
var is_in_action: bool = false
var attack_click_count: int = 0

func _ready():
	
	health_component.morreu.connect(_on_morte)
	_animation.animation_finished.connect(_on_animation_finished)
	
func _on_morte():
	print("O PLAYER MORREU!")
	# Aqui no futuro vamos chamar a animação de morte,
	# parar o movimento e desabilitar colisões.

# Pegue o @onready var do Timer que você acabou de criar
@onready var double_click_timer: Timer = $DoubleClickTimer

func _physics_process(delta):

	# Se o player está no meio de uma ação (atacando/curando),
	# ele não pode se mover e não pode começar outra ação.
	if is_in_action:
		return # Pula todo o resto da função

	# --- 1. Lógica de Movimento (só roda se NÃO estiver em ação) ---
	super(delta) 

	# --- 2. Lógica de Animação (vamos pegar a direção) ---
	var anim_sufixo = "_f" 
	if _face_direction == 1:
		anim_sufixo = "_c" 
	elif _face_direction == 2:
		anim_sufixo = "_p"

	# --- 3. Lógica de Ações ---

	# Ação de Cura (Botão B) - Continua igual
	if Input.is_action_just_pressed("curar"):
		is_in_action = true 
		_animation.play("magia_cura" + anim_sufixo) 
		health_component.curar(25.0)
		print("Player usou CURA!")

	# --- AÇÃO DE ATAQUE (LÓGICA DO CLIQUE DUPLO) ---
	elif Input.is_action_just_pressed("ataque_primario"):

		attack_click_count += 1 # Conta o clique

		if attack_click_count == 1:
			# 1º Clique: Inicia o cronômetro
			double_click_timer.start()

		elif attack_click_count == 2:
			# 2º Clique (rápido): Para o cronômetro e faz o golpe duplo!
			double_click_timer.stop()
			attack_click_count = 0 # Reseta o contador

			# --- EXECUTA O GOLPE DUPLO ---
			is_in_action = true
			_animation.play("espada_duplo" + anim_sufixo) # NOME DA SUA ANIMAÇÃO
			print("Player usou ATAQUE DUPLO!")

func _on_animation_finished(anim_name: String):
	
	# Checa se a animação que terminou é uma de "ação"
	# (Usando os nomes que você me passou!)
	if anim_name.begins_with("espada_") or anim_name.begins_with("magia_cura_"):
		
		is_in_action = false # DESTRAVA o player


func _on_double_click_timer_timeout() -> void:
	# Se o contador for 1 (só um clique), executa o golpe simples
	if attack_click_count == 1:
		# --- EXECUTA O GOLPE SIMPLES ---
		is_in_action = true

		# Pega a direção de novo, só por segurança
		var anim_sufixo = "_f" 
		if _face_direction == 1: anim_sufixo = "_c" 
		elif _face_direction == 2: anim_sufixo = "_p"

		_animation.play("espada" + anim_sufixo)
		print("Player usou ATAQUE SIMPLES!")

	# Reseta o contador
	attack_click_count = 0
