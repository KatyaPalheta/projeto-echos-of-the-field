# [Script: transicao_onda.gd]
extends CanvasLayer

# --- Ajuste os caminhos para bater com a sua cena ---
@onready var label_onda_num: Label = $VBoxContainer/AnimationPlayer/LabelOndaNum
@onready var label_tempo_titulo: Label = $VBoxContainer/LabelTempoTitulo
@onready var label_tempo_onda: Label = $VBoxContainer/LabelTempoOnda
@onready var label_tempo_total: Label = $VBoxContainer/LabelTempoTotal

@onready var botao_continuar: TextureButton = $VBoxContainer/BotaoContinuar
@onready var botao_reiniciar: TextureButton = $VBoxContainer/BotaoReiniciar
@onready var botao_sair: TextureButton = $VBoxContainer/BotaoSair

@onready var anim_player: AnimationPlayer = $VBoxContainer/AnimationPlayer

func _ready():
	get_tree().paused = true
	botao_continuar.grab_focus()
	botao_continuar.pressed.connect(_on_botao_continuar_pressed)
	botao_reiniciar.pressed.connect(_on_botao_reiniciar_pressed)
	botao_sair.pressed.connect(_on_botao_sair_pressed)
	
	if anim_player != null and anim_player.has_animation("pulsar"):
		anim_player.play("pulsar")
	else:
		Logger.log("Aviso: Animação 'pulsar' não encontrada.")

func setup(numero_onda_atual: int, tempo_gasto_na_onda: float):
	label_onda_num.text = "Onda %s Concluída!" % numero_onda_atual
	label_tempo_onda.text = "Onda: %s" % _formatar_tempo(tempo_gasto_na_onda)
	label_tempo_total.text = "Partida: %s" % SaveManager.get_tempo_total_formatado()
	
	SaveManager.dados_atuais.onda_mais_alta_salva = max(
		SaveManager.dados_atuais.onda_mais_alta_salva, 
		numero_onda_atual + 1
	)
	SaveManager.salvar_dados()

# --- Funções dos Botões ---

func _on_botao_continuar_pressed():
	get_tree().paused = false
	
	var game_manager_node = get_tree().current_scene.find_child("GameManager")
	if game_manager_node != null:
		game_manager_node.avancar_para_proxima_onda()
	else:
		# --- CORREÇÃO DO LOGGER AQUI ---
		Logger.log("[ERRO] Não achei o GameManager na cena!")
		# --- FIM DA CORREÇÃO ---
		get_tree().call_deferred("change_scene_to_file", get_tree().current_scene.scene_file_path)
	
	queue_free() 

func _on_botao_reiniciar_pressed():
	get_tree().paused = false
	if SaveManager.dados_atuais != null:
		SaveManager.dados_atuais.onda_mais_alta_salva = 1
		SaveManager.salvar_dados()
	get_tree().change_scene_to_file(get_tree().current_scene.scene_file_path)

func _on_botao_sair_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://cenas/tela_inicial.tscn") # (Confirme o caminho!)

func _formatar_tempo(tempo_em_segundos: float) -> String:
	
	# 1. O tempo já é um float!
	var tempo_float: float = tempo_em_segundos
	
	# --- CORREÇÃO AQUI ---
	# 2. Arredonda para baixo
	var minutos = int(floor(tempo_float / 60.0))
	
	# 3. Pega o "resto"
	var segundos = int(fmod(tempo_float, 60.0))
	# --- FIM DA CORREÇÃO ---
	
	return "%02d:%02d" % [minutos, segundos]
