# [Script: GameManager.gd]
# (Versão com TODAS as correções)
extends Node

signal stats_atualizadas(inimigos_mortos, inimigos_total, onda_atual)
signal onda_iniciada # <-- ADICIONADO (Bug #11)

const CENA_TRANSICAO = preload("res://HUD/transicao_onda.tscn")

var ONDAS = [
	[5, 0.005], # Onda 1
	[5, 0.005], # Onda 2
	[5, 0.005], # Onda 3
	[5, 0.005], # Onda 4
	[5, 0.005], # Onda 5
	[5, 0.005], # Onda 6
	[5, 0.005], # Onda 7
	[5, 0.005], # Onda 8
	[5, 0.005], # Onda 9
	[5, 0.005], # Onda 10
	[5, 0.005], # Onda 11
	[5, 0.005]  # Onda 12
]

var onda_atual_index: int = 0
var inimigos_mortos: int = 0
var inimigos_total_na_onda: int = 10
var player_ref: Node2D = null
var tempo_inicio_onda: float = 0.0
var timer_vitoria_onda: Timer

func _ready():
	timer_vitoria_onda = Timer.new()
	add_child(timer_vitoria_onda) 
	timer_vitoria_onda.one_shot = true 

	if SaveManager.dados_atuais != null:
		onda_atual_index = SaveManager.dados_atuais.onda_mais_alta_salva - 1
		if onda_atual_index >= ONDAS.size() or onda_atual_index < 0:
			onda_atual_index = 0 
			SaveManager.dados_atuais.onda_mais_alta_salva = 1
			SaveManager.salvar_dados()
			
	Logger.log("GameManager iniciando na Onda: %s" % (onda_atual_index + 1))

func set_player_reference(player: Node2D):
	player_ref = player

# (SUBSTITUA ESTA FUNÇÃO INTEIRA)
func iniciar_onda() -> float:
	inimigos_mortos = 0
	
	if onda_atual_index < 0 or onda_atual_index >= ONDAS.size():
		onda_atual_index = 0 
		
	if onda_atual_index == 0: 
		if SaveManager.dados_atuais != null:
			
			var save_data = SaveManager.dados_atuais
			save_data.tempo_total_gasto = 0.0 
			Logger.log("Iniciando Onda 1, cronômetro de partida zerado!")

			# ZERA todos os upgrades da partida!
			save_data.conserva_energia_entre_ondas = false
			save_data.energia_atual_salva = 0.0 # <-- ADICIONADO
			
			save_data.bonus_rajada_flechas = 0
			save_data.bonus_leque_misseis = 0
			
			save_data.bonus_vida_maxima = 0.0
			save_data.bonus_energia_maxima = 0.0
			save_data.bonus_velocidade_movimento = 0.0
			save_data.bonus_reducao_dano = 0.0 # <-- ADICIONADO
			
			save_data.bonus_potencia_cura = 0.0
			save_data.bonus_cura_por_morte = 0.0
			save_data.bonus_cargas_cura = 0
			
			save_data.bonus_dano_espada = 0.0
			save_data.bonus_dano_espada_especial = 0.0
			save_data.bonus_cadencia_arco = 0.0
			save_data.bonus_cadencia_magia = 0.0
			save_data.bonus_eficiencia_energia = 0.0

			Logger.log("SaveData resetado para início de partida.")

	var dados_onda = ONDAS[onda_atual_index]
	inimigos_total_na_onda = dados_onda[0]
	var chance_spawn = dados_onda[1]

	tempo_inicio_onda = Time.get_ticks_msec() / 1000.0
	emit_signal.call_deferred("stats_atualizadas", inimigos_mortos, inimigos_total_na_onda, onda_atual_index + 1)
	
	# AVISA O PLAYER (Bug #11)
	emit_signal("onda_iniciada") # <-- ADICIONADO
	
	return chance_spawn

func registrar_morte_inimigo():
	inimigos_mortos += 1
	emit_signal("stats_atualizadas", inimigos_mortos, inimigos_total_na_onda, onda_atual_index + 1)

	if player_ref != null:
		player_ref.ganhar_energia(25.0) 
		
		if SaveManager.dados_atuais != null:
			var cura_por_morte = SaveManager.dados_atuais.bonus_cura_por_morte
			if cura_por_morte > 0.0:
				var health_comp = player_ref.get_node_or_null("HealthComponent")
				if health_comp != null:
					health_comp.curar(cura_por_morte)

	if inimigos_mortos >= inimigos_total_na_onda and timer_vitoria_onda.is_stopped():
		var tempo_gasto = (Time.get_ticks_msec() / 1000.0) - tempo_inicio_onda
		var onda_que_terminou = onda_atual_index + 1
		var tempo_str = _formatar_tempo(tempo_gasto)
		var log_msg = "Onda %s completa em %s segundos!" % [onda_que_terminou, tempo_str]
		Logger.log(log_msg)

		onda_atual_index += 1

		if onda_atual_index >= ONDAS.size():
			Logger.log("VOCÊ VENCEU A DEMO!")
			onda_atual_index = 0 
		
		var dados_para_transicao = {
			"onda": onda_que_terminou,
			"tempo": tempo_gasto
		}
		
		timer_vitoria_onda.timeout.connect(
			_on_timer_vitoria_onda_timeout.bind(dados_para_transicao), 
			CONNECT_ONE_SHOT
		)
		
		timer_vitoria_onda.start(1.0)

# (SUBSTITUA ESTA FUNÇÃO INTEIRA)
func _on_timer_vitoria_onda_timeout(dados: Dictionary):
	# SALVA A ENERGIA ATUAL (Bug #6)
	if player_ref != null and SaveManager.dados_atuais != null:
		SaveManager.dados_atuais.energia_atual_salva = player_ref.energia_atual
		Logger.log("Energia atual (%s) salva." % player_ref.energia_atual)
	# --- FIM DA ADIÇÃO ---

	if CENA_TRANSICAO != null:
		var transicao = CENA_TRANSICAO.instantiate()
		get_tree().current_scene.add_child(transicao)
		transicao.setup(dados["onda"], dados["tempo"])

func avancar_para_proxima_onda():
	get_tree().call_deferred("change_scene_to_file", get_tree().current_scene.scene_file_path)

func _formatar_tempo(tempo_em_segundos: float) -> String:
	var tempo_float: float = tempo_em_segundos
	var minutos = int(floor(tempo_float / 60.0))
	var segundos = int(fmod(tempo_float, 60.0))
	return "%02d:%02d" % [minutos, segundos]
