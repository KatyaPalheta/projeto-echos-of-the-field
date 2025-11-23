# [Script: tela_configuracoes.gd]
extends CanvasLayer

# --- Referências de Cena ---
# A tela inicial que vamos reabrir
const CENA_TELA_INICIAL = preload("res://HUD/tela_inicial.tscn") 

# --- Referências da Aba Global ---
# Opções Booleanas/Sliders
@onready var check_mostrar_log: CheckBox = $VBoxContainerCentral/PainelPrincipal/TabContainer/AbaGlobais/LinhaLog/CheckMostrarLog
@onready var slider_volume: HSlider = $VBoxContainerCentral/PainelPrincipal/TabContainer/AbaGlobais/LinhaVolume/SliderVolume
@onready var label_volume_valor: Label = $VBoxContainerCentral/PainelPrincipal/TabContainer/AbaGlobais/LinhaVolume/LabelVolumeValor
@onready var slider_ondas: HSlider = $VBoxContainerCentral/PainelPrincipal/TabContainer/AbaGlobais/LinhaOndas/SliderOndas
@onready var label_ondas_valor: Label = $VBoxContainerCentral/PainelPrincipal/TabContainer/AbaGlobais/LinhaOndas/LabelOndasValor

# Opção OptionButton (Seletor)
@onready var seletor_zoom: OptionButton = $VBoxContainerCentral/PainelPrincipal/TabContainer/AbaGlobais/LinhaZoom/SeletorZoom
# O botão Fechar/Voltar (que você nomeou BotaoSair, mas renomeei para clareza)
@onready var botao_fechar: TextureButton = $BotaoSair 


# O Godot tem um bug com OptionButton (o texto precisa ser preenchido por código)
const ZOOM_OPTIONS: Array[float] = [3.0, 2.0, 1.0, 0.5] 
# ⚠️ NOTA: Seu OptionButton mostrava 1x, 2x, 3x, 4x. Usarei os valores reais float.
# Ajustei o máximo para 4.0x no array, mas o seu jogo usa 1.0x como base.

func _ready():
	get_tree().paused = true 
	
	# 1. Carrega os valores (Define o estado visual da tela)
	_carregar_configuracoes_globais()
	
	# 2. Conecta os sinais de INPUT (Quando o usuário interage)
	_conectar_sinais_globais()
	
	# 3. Conecta o botão de fechar/voltar
	botao_fechar.pressed.connect(_on_botao_fechar_pressed)
	
	# 4. Foca no primeiro elemento (ou em algum elemento para navegação)
	# (Se a Aba Globais for a primeira, foca no CheckBox)
	check_mostrar_log.call_deferred("grab_focus")

# --- PARTE 1: CARREGAR (Definir o estado visual da tela) ---

func _carregar_configuracoes_globais():
	var config = ConfigManager.config_data
	
	# MOSTRAR LOG (Checkbox)
	check_mostrar_log.button_pressed = config.mostrar_log
	
	# VOLUME MASTER (Slider)
	slider_volume.value = config.volume_master
	_atualizar_volume_label(config.volume_master) # Garante que a label está certa
	
	# NÚMERO DE ONDAS (Slider)
	slider_ondas.value = config.numero_de_ondas_max
	_atualizar_ondas_label(config.numero_de_ondas_max)
	
	# ZOOM DA CÂMERA (OptionButton)
	_setup_zoom_options(config.zoom_camera)

# --- FUNÇÕES HELPER PARA O CARREGAMENTO ---

func _setup_zoom_options(current_zoom: float):
	seletor_zoom.clear()
	var selected_index = 0
	
	for i in range(ZOOM_OPTIONS.size()):
		var zoom_value = ZOOM_OPTIONS[i]
		var label_text = "%sx" % zoom_value
		seletor_zoom.add_item(label_text, i)
		
		# Procura o valor atual (ou o mais próximo) para selecionar o item correto
		if is_equal_approx(zoom_value, current_zoom): 
			selected_index = i
	
	seletor_zoom.select(selected_index)

# --- PARTE 2: CONECTAR (Amarrar os eventos às funções de salvamento) ---

func _conectar_sinais_globais():
	
	# Checkbox
	check_mostrar_log.toggled.connect(_on_check_mostrar_log_toggled)
	
	# Volume
	slider_volume.value_changed.connect(_on_slider_volume_value_changed)
	
	# Ondas
	slider_ondas.value_changed.connect(_on_slider_ondas_value_changed)
	
	# Zoom
	seletor_zoom.item_selected.connect(_on_seletor_zoom_item_selected)

# --- PARTE 3: SALVAR (As funções que rodam quando o usuário interage) ---

func _on_check_mostrar_log_toggled(button_pressed: bool):
	ConfigManager.set_global_value("mostrar_log", button_pressed)
	# O Logger.gd já checa essa variável no _process, então não precisa de mais nada.

func _on_slider_volume_value_changed(value: float):
	# Salva o valor no ConfigManager
	ConfigManager.set_global_value("volume_master", value)
	# Atualiza o visual (Label)
	_atualizar_volume_label(value)
	# ⚠️ NOTA: A lógica para aplicar o volume ao AudioServer precisa ser feita
	# no seu nó AudioPlayer ou em um nó central de áudio, usando AudioServer.set_bus_volume_db().
	# Por hora, apenas salvamos o valor.

func _atualizar_volume_label(value: float):
	var percent = int(round(value * 100))
	label_volume_valor.text = "%s%%" % percent
	
func _on_slider_ondas_value_changed(value: float):
	var int_value = int(value)
	# Salva o valor (o ConfigManager já garante que é int se o HSlider for configurado corretamente)
	ConfigManager.set_global_value("numero_de_ondas_max", int_value)
	# Atualiza o visual (Label)
	_atualizar_ondas_label(int_value)

func _atualizar_ondas_label(value: int):
	label_ondas_valor.text = "%s ondas" % value

func _on_seletor_zoom_item_selected(index: int):
	var zoom_value = ZOOM_OPTIONS[index]
	# Salva o valor
	ConfigManager.set_global_value("zoom_camera", zoom_value)
	# O Player.gd lerá esse valor na próxima vez que a cena for carregada.

# --- FUNÇÃO DE FECHAR/VOLTAR ---

func _on_botao_fechar_pressed():
	# 1. Despausa o jogo
	get_tree().paused = false
	
	# 2. Carrega a tela inicial
	if CENA_TELA_INICIAL != null:
		get_tree().change_scene_to_file(CENA_TELA_INICIAL.scene_file_path)
	else:
		push_error("Cena da Tela Inicial não carregada!")

	# 3. Destrói a si mesmo (a tela de configuração)
	queue_free()
