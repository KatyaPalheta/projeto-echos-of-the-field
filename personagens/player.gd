# [Script: player.gd]
extends "res://personagens/personagem_base.gd"

signal vida_atualizada(vida_atual, vida_maxima)
signal player_morreu
signal cargas_cura_mudou(cargas_restantes)
signal energia_mudou(energia_atual, energia_maxima)

@onready var mira_sprite: Sprite2D = $textura/Mira
@onready var cone_de_mira: Area2D = $ConeDeMira
@onready var health_component: HealthComponent = $HealthComponent
@onready var audio_arco_puxar: AudioStreamPlayer2D = $AudioArcoPuxar
@onready var audio_cast_magia: AudioStreamPlayer2D = $AudioCastMagia
@onready var arco_cooldown_timer: Timer = $ArcoCooldownTimer
@onready var magia_cooldown_timer: Timer = $MagiaCooldownTimer
@onready var state_machine = $StateMachine

@export_category("Stats de Combate")
@export var cadencia_arco_base: float = 0.8
@export var cadencia_magia_base: float = 1.0 
@export var dano_espada_base: float = 25.0
@export var dano_espada_especial: float = 50.0
@export var potencia_cura_base: float = 25.0

@export var cena_flecha: PackedScene 
@export var cena_missil_de_fogo: PackedScene

var is_dead: bool = false 
var cargas_de_cura: int = 3
var energia_maxima: float = 100.0
var energia_atual: float = 0.0
var custo_ataque_especial: float = 50.00 
var current_attack_damage = 25.0
var alvo_travado: Node2D = null

# (SUBSTITUA ESTA FUNÇÃO INTEIRA)
func _ready():
	# 1. CONECTA ao sinal do GameManager
	if GameManager != null:
		GameManager.onda_iniciada.connect(aplicar_upgrades_da_partida) 

	# 2. Conecta os sinais locais
	health_component.morreu.connect(_on_morte) 
	health_component.vida_mudou.connect(_on_health_component_vida_mudou) 
	_animation.animation_finished.connect(_on_animation_finished) 
	
	# 3. Avisa a HUD (isso será corrigido pela função aplicar_upgrades)
	emit_signal.call_deferred("cargas_cura_mudou", cargas_de_cura) 
	
	Logger.log("Player _ready() executado. Aguardando sinal 'onda_iniciada'...") 


# Esta função é chamada pelo SINAL 'onda_iniciada' do GameManager
func aplicar_upgrades_da_partida():
	Logger.log("Sinal 'onda_iniciada' recebido! Aplicando upgrades...") 
	
	if SaveManager.dados_atuais != null:
		var save = SaveManager.dados_atuais
		
		# 1. Aplica Bônus de Vida
		health_component.aplicar_bonus_de_vida(save.bonus_vida_maxima) 
		
		# 2. Aplica Bônus de Energia
		energia_maxima = 100.0 # Reseta a base
		energia_maxima += save.bonus_energia_maxima 
		
		# 3. Aplica Bônus de Cargas de Cura
		cargas_de_cura = 3 # Reseta para 3
		cargas_de_cura += save.bonus_cargas_cura 
		cargas_de_cura = min(cargas_de_cura, 3) 
		
		# 4. Aplica Bônus de Cadência (Arco)
		var nova_cadencia_arco = cadencia_arco_base - save.bonus_cadencia_arco 
		arco_cooldown_timer.wait_time = max(0.1, nova_cadencia_arco) 
		
		# 5. Aplica Bônus de Cadência (Magia)
		var nova_cadencia_magia = cadencia_magia_base - save.bonus_cadencia_magia 
		magia_cooldown_timer.wait_time = max(0.1, nova_cadencia_magia) 
		
		Logger.log("Stats do Player atualizadas com bônus!") 
	
	# 6. Avisa a HUD (agora com os valores corretos)
	emit_signal.call_deferred("cargas_cura_mudou", cargas_de_cura) 
	
	# 7. Reseta a energia (agora no lugar certo)
	resetar_para_proxima_onda.call_deferred() 

func _physics_process(_delta):
	
	# --- CÓDIGO DE DEBUG TEMPORÁRIO ---
	if Input.is_action_just_pressed("ui_accept"): # (Tecla "Espaço" ou "Enter") 
		if UpgradeDatabase != null and SaveManager != null:
			# Pega um ID aleatório do banco de dados
			var upgrades_ids = UpgradeDatabase.DB.keys() 
			upgrades_ids.shuffle() 
			var id_aleatorio = upgrades_ids[0] 
			
			# Simula a escolha!
			SaveManager.registrar_upgrade_escolhido(id_aleatorio) 
			Logger.log("[DEBUG] Registrando upgrade de teste: %s" % id_aleatorio) 
	# --- FIM DO DEBUG ---

	if Input.is_action_just_pressed("ui_pausar"): 
		var pause_menu_scene = load("res://HUD/pause_menu.tscn") 
		var pause_instance = pause_menu_scene.instantiate() 
		add_child(pause_instance) 
		return 

	if is_dead: 
		velocity = Vector2.ZERO 
		move_and_slide() 
		return 
	pass 

func _input(_event):
	pass 

func _on_morte():
	if is_dead: 
		return 
	is_dead = true 
	set_physics_process(false) 
	var anim_sufixo = "_f" 
	if _face_direction == 1: anim_sufixo = "_c" 
	elif _face_direction == 2: anim_sufixo = "_p" 
	_animation.play("morte" + anim_sufixo) 
	$AudioDead.play() 
	$colisao.set_deferred("disabled", true) 
	emit_signal("player_morreu") 
	var tween = create_tween() 
	tween.tween_property($Camera2D, "zoom", Vector2(1.5, 1.5), 2.0).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT) 
	var game_over_scene = load("res://HUD/game_over_screen.tscn") 
	var game_over_instance = game_over_scene.instantiate() 
	add_child(game_over_instance) 
	Logger.log("O PLAYER MORREU!") 

# (SUBSTITUA ESTA FUNÇÃO INTEIRA)
func receber_dano_do_inimigo(dano: float, direcao_do_ataque: Vector2):
	var estado_atual_str = state_machine.current_state.name 
	if is_dead or estado_atual_str == "Hurt": 
		return 

	Logger.log(">>> DANO RECEBIDO! Posição atual: %s" % global_position) 

	var bonus_reducao = 0.0 
	if SaveManager.dados_atuais != null:
		bonus_reducao = SaveManager.dados_atuais.bonus_reducao_dano 
	
	var dano_final = max(0.0, dano - bonus_reducao) 
	Logger.log("Dano original: %s. Redução: %s. Dano Final: %s" % [dano, bonus_reducao, dano_final]) 
	
	health_component.sofrer_dano(dano_final) 
	
	if health_component.vida_atual > 0.0: 
		var hurt_state = state_machine.get_node("Hurt") 
		hurt_state.setup_knockback(direcao_do_ataque) 
		state_machine._change_state(hurt_state) 

func _on_animation_finished(_anim_name: String):
	pass 

func _on_hit_box_espada_body_entered(body: Node2D) -> void:
	if body.is_in_group("damageable_enemy"): 
		var direcao_do_ataque = (body.global_position - global_position).normalized() 
		body.sofrer_dano(current_attack_damage, direcao_do_ataque) 
		Logger.log("ACERTEI O INIMIGO: %s" % body.name) 

func _on_health_component_vida_mudou(vida_atual: float, vida_maxima: float):
	emit_signal.call_deferred("vida_atualizada", vida_atual, vida_maxima) 

func ganhar_energia(quantidade: float):
	energia_atual = min(energia_maxima, energia_atual + quantidade) 
	emit_signal("energia_mudou", energia_atual, energia_maxima) 
	Logger.log("Energia ganha! Total: %s" % int(energia_atual)) 

# (SUBSTITUA ESTA FUNÇÃO INTEIRA)
func resetar_para_proxima_onda():
	if SaveManager.dados_atuais.conserva_energia_entre_ondas: 
		# Lê a energia que o GameManager salvou
		energia_atual = SaveManager.dados_atuais.energia_atual_salva 
		Logger.log("Energia CONSERVADA: %s" % energia_atual) 
	else:
		energia_atual = 0.0 
		Logger.log("Energia RESETADA.") 
	
	emit_signal("energia_mudou", energia_atual, energia_maxima) 

func _disparar_flecha(sufixo_anim: String):
	if cena_flecha == null: 
		push_warning("Cena da Flecha não configurada no Player!") 
		return 
	var flecha = cena_flecha.instantiate() 
	var direcao_disparo: Vector2
	if alvo_travado != null: 
		direcao_disparo = (alvo_travado.global_position - global_position).normalized() 
	else:
		if sufixo_anim == "_c": 
			direcao_disparo = Vector2.UP 
		elif sufixo_anim == "_p": 
			direcao_disparo = Vector2.RIGHT if not _sprite.flip_h else Vector2.LEFT 
		else: 
			direcao_disparo = Vector2.DOWN 
	flecha.direcao = direcao_disparo 
	flecha.global_position = global_position 
	get_parent().add_child(flecha) 

func _atualizar_alvo_com_cone(sufixo_anim: String):
	if sufixo_anim == "_c": 
		cone_de_mira.rotation = PI 
	elif sufixo_anim == "_p": 
		cone_de_mira.rotation = PI / 2.0 if _sprite.flip_h else -PI / 2.0 
	else: 
		cone_de_mira.rotation = 0 
	var corpos_no_cone = cone_de_mira.get_overlapping_bodies() 
	if corpos_no_cone.is_empty(): 
		alvo_travado = null 
		return 
	var inimigo_mais_proximo: Node2D = null 
	var menor_distancia_quadrada: float = INF 
	for corpo in corpos_no_cone:
		if corpo.is_in_group("damageable_enemy"): 
			var dist_quadrada = global_position.distance_squared_to(corpo.global_position) 
			if dist_quadrada < menor_distancia_quadrada: 
				menor_distancia_quadrada = dist_quadrada 
				inimigo_mais_proximo = corpo 
	alvo_travado = inimigo_mais_proximo 

# (SUBSTITUA ESTA FUNÇÃO INTEIRA)
func _disparar_rajada_de_flechas(sufixo_anim: String):
	if cena_flecha == null: 
		push_warning("Cena da Flecha não configurada no Player!") 
		return 
	
	var flechas_base = 2 
	var bonus_flechas = 0 
	var bonus_velocidade_rajada = 0.0 # (Bônus em segundos) 
	
	if SaveManager.dados_atuais != null:
		bonus_flechas = SaveManager.dados_atuais.bonus_rajada_flechas 
		bonus_velocidade_rajada = SaveManager.dados_atuais.bonus_velocidade_rajada 
	
	var total_flechas = flechas_base + bonus_flechas 
	
	var delay_base_entre_flechas = 0.35 # (O valor original) 
	
	# O bônus REDUZ o delay, com um mínimo de 0.1s para não ser instantâneo
	var delay_final = max(0.1, delay_base_entre_flechas - bonus_velocidade_rajada) 
	
	for i in range(total_flechas): 
		if is_dead: return 
		
		_disparar_flecha(sufixo_anim) 
		
		if i < (total_flechas - 1): 
			await get_tree().create_timer(delay_final).timeout 

func _disparar_missil(sufixo_anim: String):
	if cena_missil_de_fogo == null: 
		push_warning("Cena do Míssil de Fogo não configurada no Player!") 
		return 
	var missil = cena_missil_de_fogo.instantiate() 
	var direcao_disparo: Vector2
	if alvo_travado != null: 
		direcao_disparo = (alvo_travado.global_position - global_position).normalized() 
	else:
		if sufixo_anim == "_c": 
			direcao_disparo = Vector2.UP 
		elif sufixo_anim == "_p": 
			direcao_disparo = Vector2.RIGHT if not _sprite.flip_h else Vector2.LEFT 
		else: 
			direcao_disparo = Vector2.DOWN 
	missil.direcao = direcao_disparo 
	missil.global_position = global_position 
	get_parent().add_child(missil) 

# (SUBSTITUA ESTA FUNÇÃO INTEIRA)
func _disparar_leque_de_misseis(sufixo_anim: String):
	if cena_missil_de_fogo == null: 
		push_warning("Cena do Míssil de Fogo não configurada no Player!") 
		return 

	var misseis_base = 2 
	var bonus_misseis = 0 
	var bonus_foco_graus = 0.0 
	
	if SaveManager.dados_atuais != null:
		bonus_misseis = SaveManager.dados_atuais.bonus_leque_misseis 
		bonus_foco_graus = SaveManager.dados_atuais.bonus_foco_leque 
		
	var quantidade_misseis = misseis_base + bonus_misseis 
	
	var angulo_passo_base_graus = 10.0 
	var angulo_passo_final_graus = max(1.0, angulo_passo_base_graus - bonus_foco_graus) 
	var angulo_passo_rad = deg_to_rad(angulo_passo_final_graus) 
	
	var direcao_base: Vector2
	if sufixo_anim == "_c": 
		direcao_base = Vector2.UP 
	elif sufixo_anim == "_p": 
		direcao_base = Vector2.RIGHT if not _sprite.flip_h else Vector2.LEFT 
	else: 
		direcao_base = Vector2.DOWN 
	
	var angulo_inicial: float = -(float(quantidade_misseis - 1) / 2.0) * angulo_passo_rad 
	
	for i in range(quantidade_misseis): 
		var angulo_offset = angulo_inicial + (i * angulo_passo_rad) 
		var direcao_atual = direcao_base.rotated(angulo_offset) 
		
		var missil = cena_missil_de_fogo.instantiate() 
		missil.direcao = direcao_atual 
		missil.global_position = global_position 
		get_parent().add_child(missil) 
