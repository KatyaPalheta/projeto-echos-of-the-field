extends "res://personagens/personagem_base.gd"
signal vida_atualizada(vida_atual, vida_maxima)
signal player_morreu
@onready var health_component: HealthComponent = $HealthComponent
# @onready var double_click_timer: Timer = $DoubleClickTimer <-- REMOVIDO!
var is_in_action: bool = false
var is_dead: bool = false
# var attack_click_count: int = 0 <-- REMOVIDO!

func _ready():
	health_component.morreu.connect(_on_morte)
	health_component.vida_mudou.connect(_on_health_component_vida_mudou)
	_animation.animation_finished.connect(_on_animation_finished)
	emit_signal.call_deferred("vida_atualizada", health_component.vida_atual, health_component.vida_maxima)
	# Não precisamos mais conectar o timer!
	
func _on_morte():
	# Se já estiver morto, não faz nada
	if is_dead:
		return

	is_dead = true
	is_in_action = true # Trava o player de outras ações
	set_physics_process(false) # Para o movimento

	# Pega a direção atual para a animação
	var anim_sufixo = "_f" 
	if _face_direction == 1: anim_sufixo = "_c" 
	elif _face_direction == 2: anim_sufixo = "_p"

	# 1. Toca a animação de morte
	_animation.play("morte" + anim_sufixo) # <-- SUAS ANIMAÇÕES!

	# 2. Desativa a colisão do player
	$colisao.disabled = true # (Confirme se o nome é esse)

	# 3. Avisa ao JOGO INTEIRO que o player morreu
	emit_signal("player_morreu")

	print("O PLAYER MORREU (DE VERDADE AGORA)!")

func _physics_process(delta):

	# Se o player está no meio de uma ação (atacando/curando),
	# ele não pode se mover e não pode começar outra ação.
	if is_in_action:
		return # Pula todo o resto da função [cite: 52]

	# --- 1. Lógica de Movimento (só roda se NÃO estiver em ação) ---
	super(delta) 

	# --- 2. Lógica de Animação (vamos pegar a direção) ---
	var anim_sufixo = "_f" 
	if _face_direction == 1:
		anim_sufixo = "_c" 
	elif _face_direction == 2:
		anim_sufixo = "_p"

	# --- 3. Lógica de Ações (LÓGICA NOVA E RESPONSIVA) ---

	# Checa se o player está SEGURANDO o botão do ARCO (LB)
	if Input.is_action_pressed("equip_arco"):
		
		if Input.is_action_just_pressed("ataque_primario"): # LB + X
			is_in_action = true
			# _animation.play("arco_simples" + anim_sufixo)
			print("Player usou ARCO SIMPLES!")
			
		elif Input.is_action_just_pressed("ataque_especial"): # LB + Y
			is_in_action = true
			# _animation.play("arco_chuva" + anim_sufixo)
			print("Player usou CHUVA DE FLECHA!")

	# Checa se o player está SEGURANDO o botão de MAGIA (RB)
	elif Input.is_action_pressed("equip_magia"):
		
		if Input.is_action_just_pressed("ataque_primario"): # RB + X
			is_in_action = true
			# _animation.play("magia_fogo_simples" + anim_sufixo)
			print("Player usou FOGO SIMPLES!")
			
		elif Input.is_action_just_pressed("ataque_especial"): # RB + Y
			is_in_action = true
			# _animation.play("magia_fogo_master" + anim_sufixo)
			print("Player usou FOGO MASTER BLASTER!")

	# --- Ações Padrão (sem modificador pressionado) ---

	# Ação de Cura (Botão B)
	elif Input.is_action_just_pressed("curar"):
		is_in_action = true 
		_animation.play("magia_cura" + anim_sufixo) 
		health_component.curar(25.0)
		print("Player usou CURA!")

	# Ação de Ataque Simples (Botão X) - AGORA É IMEDIATO!
	elif Input.is_action_just_pressed("ataque_primario"):
		is_in_action = true
		_animation.play("espada" + anim_sufixo) # A animação de golpe simples
		print("Player usou ATAQUE SIMPLES!")

	# Ação de Ataque Duplo/Especial (Botão Y) - AGORA É IMEDIATO!
	elif Input.is_action_just_pressed("ataque_especial"):
		is_in_action = true
		_animation.play("espada_duplo" + anim_sufixo) # A animação de golpe duplo [cite: 53]
		print("Player usou ATAQUE DUPLO!")

func _on_animation_finished(anim_name: String):
	
	# Checa se a animação que terminou é uma de "ação"
	# (Adicione os nomes das animações de arco/magia aqui quando as tiver)
	if anim_name.begins_with("espada_") or \
	   anim_name.begins_with("magia_cura_") or \
	   anim_name.begins_with("espada_duplo_") or \
	   anim_name.begins_with("hurt_"): # <-- ADICIONE ISSO AQUI
		
		is_in_action = false # DESTRAVA o player


# --- FUNÇÃO REMOVIDA ---
# func _on_double_click_timer_timeout() -> void:
#	(Todo o conteúdo desta função foi removido) 


func _on_hit_box_espada_body_entered(body: Node2D) -> void:
	# 1. Checa se o que acertamos tem o "adesivo" que criamos
	if body.is_in_group("damageable_enemy"):
		
		# 2. Calcula a direção do ataque (do player para o inimigo)
		var direcao_do_ataque = (body.global_position - global_position).normalized()
		
		# 3. Chama a função que JÁ EXISTE no inimigo!
		body.sofrer_dano(25.0, direcao_do_ataque)
		
		print("ACERTEI O INIMIGO: ", body.name)
func receber_dano_do_inimigo(dano: float, direcao_do_ataque: Vector2):
	# Se já estivermos mortos ou no meio de uma ação (como rolar, no futuro)
	if health_component.vida_atual == 0.0 or is_in_action:
		return 

	# 1. Aplica o dano
	health_component.sofrer_dano(dano)
	
	# 2. SE NÃO MORREU, toca a animação "hurt_"
	if health_component.vida_atual > 0.0:
		is_in_action = true # Trava o player para ele não andar
		
		# Pega a direção DE ONDE VEIO O ATAQUE para a animação
		var anim_sufixo = "_f" 
		if direcao_do_ataque.y < -0.5: # Veio de cima (acertou as costas)
			anim_sufixo = "_c"
		elif abs(direcao_do_ataque.x) > 0.5: # Veio dos lados
			anim_sufixo = "_p"
		# (Se veio de baixo, usa "_f" mesmo)

		_animation.play("hurt" + anim_sufixo) # <-- SUAS ANIMAÇÕES!
		
		# (Opcional: Adicionar um leve knockback)
		velocity = direcao_do_ataque * 300.0 # Ajustar valor
		
	# Esta função "ouve" o sinal INTERNO do HealthComponent...
func _on_health_component_vida_mudou(vida_atual: float, vida_maxima: float):
	
	# ...e "grita" o SINAL PÚBLICO para o mundo exterior (o GameLevel)
	emit_signal("vida_atualizada", vida_atual, vida_maxima)
