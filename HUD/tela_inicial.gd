# [Script: tela_inicial.gd]
extends CanvasLayer

# --- Referências de Cena ---
const CENA_JOGO = preload("res://cenas/game_level.tscn") # ⚠️ Confirme este caminho!
const CENA_CONFIG = preload("res://HUD/tela_configuracoes.tscn") # ⚠️ Criaremos este .tscn depois

# --- Referências de Botões ---
@onready var botao_novo_jogo: TextureButton = $VBoxContainer/BotaoNovoJogo
@onready var botao_continuar: TextureButton = $VBoxContainer/BotaoContinuar
@onready var botao_config: TextureButton = $VBoxContainer/BotaoConfig
@onready var botao_sair: TextureButton = $VBoxContainer/BotaoSair

func _ready():
	get_tree().paused = false # Garante que o jogo não está pausado

	# 1. Conecta todos os sinais dos botões
	botao_novo_jogo.pressed.connect(_on_botao_novo_jogo_pressed)
	botao_continuar.pressed.connect(_on_botao_continuar_pressed)
	botao_config.pressed.connect(_on_botao_config_pressed)
	botao_sair.pressed.connect(_on_botao_sair_pressed)
	
	# 2. Verifica se o botão "Continuar" deve aparecer
	var ondas_salvas = 0
	if SaveManager.dados_atuais != null:
		ondas_salvas = SaveManager.dados_atuais.onda_mais_alta_salva
	
	# O botão "Continuar" só deve aparecer se houver progresso real (Onda 2 ou mais)
	var tem_progresso_salvo = ondas_salvas > 1
	botao_continuar.visible = tem_progresso_salvo
	
	# 3. Define o foco inicial
	if tem_progresso_salvo:
		# Se há progresso, foca em Continuar
		botao_continuar.call_deferred("grab_focus")
	else:
		# Se não há progresso, foca em Novo Jogo
		botao_novo_jogo.call_deferred("grab_focus")


# --- FUNÇÕES DE BOTÃO ---

func _on_botao_novo_jogo_pressed():
	# 1. ZERA O PROGRESSO NO SAVE
	if SaveManager.dados_atuais != null:
		SaveManager.dados_atuais.onda_mais_alta_salva = 1
		SaveManager.salvar_dados()
		
	# 2. ZERA O PROGRESSO NA MEMÓRIA
	GameManager.onda_atual_index = 0
	
	# 3. Inicia o jogo na primeira cena
	if CENA_JOGO != null:
		get_tree().change_scene_to_file(CENA_JOGO.scene_file_path)
	else:
		push_error("Cena de Jogo (game_level.tscn) não carregada!")

func _on_botao_continuar_pressed():
	# 1. Apenas carrega a cena de jogo, o GameManager já carrega o índice salvo
	if CENA_JOGO != null:
		get_tree().change_scene_to_file(CENA_JOGO.scene_file_path)
	else:
		push_error("Cena de Jogo (game_level.tscn) não carregada!")

func _on_botao_config_pressed():
	# Carrega a tela de configurações (próximo passo visual)
	if CENA_CONFIG != null:
		var tela_config = CENA_CONFIG.instantiate()
		get_tree().root.add_child(tela_config)
		# Nota: Esta tela não pausa o jogo, mas se autodestrói ao sair
		queue_free() # Remove a Tela Inicial
	else:
		push_error("Cena de Configurações não carregada!")
		
func _on_botao_sair_pressed():
	get_tree().quit() # Fecha o jogo
