# [Em: GameManager.gd]
# (Versão final com o "Respiro" de 1 segundo)

extends Node

signal stats_atualizadas(inimigos_mortos, inimigos_total, onda_atual)

const CENA_TRANSICAO = preload("res://HUD/transicao_onda.tscn") # (Confirme o caminho!)

var ONDAS = [
	[3, 0.005], # Onda 1
	[6, 0.008], # Onda 2
	[9, 0.01]  # Onda 3
]

var onda_atual_index: int = 0
var inimigos_mortos: int = 0
var inimigos_total_na_onda: int = 10
var player_ref: Node2D = null
var tempo_inicio_onda: float = 0.0

# --- O NOSSO TIMER DE "RESPIRO"! ---
var timer_vitoria_onda: Timer

func _ready():
	# --- CRIA O TIMER EM TEMPO REAL ---
	# (Já que o GameManager é um Autoload só de script)
	timer_vitoria_onda = Timer.new()
	add_child(timer_vitoria_onda) # Adiciona o timer a si mesmo
	timer_vitoria_onda.one_shot = true # Garante que ele só toque uma vez
	# --- FIM DA CRIAÇÃO DO TIMER ---

	if SaveManager.dados_atuais != null:
		onda_atual_index = SaveManager.dados_atuais.onda_mais_alta_salva - 1
		if onda_atual_index >= ONDAS.size() or onda_atual_index < 0:
			onda_atual_index = 0 
			SaveManager.dados_atuais.onda_mais_alta_salva = 1
			SaveManager.salvar_dados()
			
	Logger.log("GameManager iniciando na Onda: %s" % (onda_atual_index + 1))

func set_player_reference(player: Node2D):
	player_ref = player

func iniciar_onda() -> float:
	# ... (esta função continua igual à anterior) ...
	inimigos_mortos = 0
	if onda_atual_index < 0 or onda_atual_index >= ONDAS.size():
		onda_atual_index = 0 
	var dados_onda = ONDAS[onda_atual_index]
	inimigos_total_na_onda = dados_onda[0]
	var chance_spawn = dados_onda[1]
	tempo_inicio_onda = Time.get_ticks_msec() / 1000.0
	emit_signal.call_deferred("stats_atualizadas", inimigos_mortos, inimigos_total_na_onda, onda_atual_index + 1)
	return chance_spawn

func registrar_morte_inimigo():
	inimigos_mortos += 1
	emit_signal("stats_atualizadas", inimigos_mortos, inimigos_total_na_onda, onda_atual_index + 1)

	if player_ref != null:
		player_ref.ganhar_energia(25.0) 
	
	# Checa se a onda acabou E se o timer NÃO está rodando
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
		
		# --- A LÓGICA DO DELAY! ---
		# 1. Prepara os dados que vamos enviar
		var dados_para_transicao = {
			"onda": onda_que_terminou,
			"tempo": tempo_gasto
		}
		
		# 2. Conecta o sinal 'timeout' do timer à nossa função,
		#    passando os dados para ela. (CONNECT_ONE_SHOT se autodestrói)
		timer_vitoria_onda.timeout.connect(
			_on_timer_vitoria_onda_timeout.bind(dados_para_transicao), 
			CONNECT_ONE_SHOT
		)
		
		# 3. INICIA O TIMER DE 1 SEGUNDO!
		timer_vitoria_onda.start(1.0)
		# --- FIM DA LÓGICA ---
		
		# (As linhas que instanciam a cena foram MOVIDAS
		#  para a função do timer abaixo)

# --- FUNÇÃO TOTALMENTE NOVA ---
# (Esta função só roda 1 segundo DEPOIS da vitória)
func _on_timer_vitoria_onda_timeout(dados: Dictionary):
	if CENA_TRANSICAO != null:
		var transicao = CENA_TRANSICAO.instantiate()
		get_tree().current_scene.add_child(transicao)
		
		# Pega os dados que o timer "segurou" para nós
		transicao.setup(dados["onda"], dados["tempo"])

func avancar_para_proxima_onda():
	get_tree().call_deferred("change_scene_to_file", get_tree().current_scene.scene_file_path)

func _formatar_tempo(tempo_em_segundos: float) -> String:
	var tempo_float: float = tempo_em_segundos
	var minutos = int(floor(tempo_float / 60.0))
	var segundos = int(fmod(tempo_float, 60.0))
	return "%02d:%02d" % [minutos, segundos]
