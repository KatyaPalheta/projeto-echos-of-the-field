# [Script: tela_configuracoes.gd]
extends CanvasLayer

# --- Referências de Cena ---
# A tela inicial que vamos reabrir
const CENA_TELA_INICIAL = preload("res://HUD/tela_inicial.tscn")
const ZOOM_OPTIONS: Array[float] = [3.0, 2.0, 1.0, 0.5] 
const VIDA_OPTIONS: Array[float] = [100.0, 200.0, 300.0, 400.0]
const ENERGIA_OPTIONS: Array[float] = [100.0, 200.0, 300.0, 400.0]
const CURAS_OPTIONS: Array[int] = [3, 6, 9]
const POTENCIA_CURA_OPTIONS: Array[float] = [25.0, 50.0, 100.0]

# --- Referências da Aba Global ---
# Opções Booleanas/Sliders
@onready var check_mostrar_log: CheckBox = $VBoxContainerCentral/PainelPrincipal/TabContainer/AbaGlobais/LinhaLog/CheckMostrarLog
@onready var slider_volume: HSlider = $VBoxContainerCentral/PainelPrincipal/TabContainer/AbaGlobais/LinhaVolume/SliderVolume
@onready var label_volume_valor: Label = $VBoxContainerCentral/PainelPrincipal/TabContainer/AbaGlobais/LinhaVolume/LabelVolumeValor
@onready var slider_ondas: HSlider = $VBoxContainerCentral/PainelPrincipal/TabContainer/AbaGlobais/LinhaOndas/SliderOndas
@onready var label_ondas_valor: Label = $VBoxContainerCentral/PainelPrincipal/TabContainer/AbaGlobais/LinhaOndas/LabelOndasValor
@onready var seletor_vida: OptionButton = $VBoxContainerCentral/PainelPrincipal/TabContainer/AbaGameplay/LinhaVidaPlayer/SeletorVidaPlayer
@onready var seletor_energia: OptionButton = $VBoxContainerCentral/PainelPrincipal/TabContainer/AbaGameplay/LinhaEnergiaPlayer/SeletorEnergiaPlayer
@onready var check_energia_carregada: CheckBox = $VBoxContainerCentral/PainelPrincipal/TabContainer/AbaGameplay/LinhaEnergiaCarregada/CheckEnergiaCarregada
@onready var seletor_curas: OptionButton = $VBoxContainerCentral/PainelPrincipal/TabContainer/AbaGameplay/LinhaNumeroCura/SeletorNumeroCura
@onready var seletor_potencia_cura: OptionButton = $VBoxContainerCentral/PainelPrincipal/TabContainer/AbaGameplay/LinhaCuraBase/SeletorCuraBase
@onready var check_progressiva: CheckBox = $VBoxContainerCentral/PainelPrincipal/TabContainer/AbaDificuldade/LinhaProgressiva/CheckProgressiva
@onready var seletor_preset: OptionButton = $VBoxContainerCentral/PainelPrincipal/TabContainer/AbaDificuldade/LinhaPreset/SeletorPreset
@onready var seletor_zoom: OptionButton = $VBoxContainerCentral/PainelPrincipal/TabContainer/AbaGlobais/LinhaZoom/SeletorZoom
@onready var botao_fechar: TextureButton = $BotaoSair 

@onready var label_vida_monstro: Label = $VBoxContainerCentral/PainelPrincipal/TabContainer/AbaDificuldade/LinhaVidaMonstroValor
@onready var label_dano_monstro: Label = $VBoxContainerCentral/PainelPrincipal/TabContainer/AbaDificuldade/LinhaDanoMonstroValor
@onready var label_total_monstro: Label = $VBoxContainerCentral/PainelPrincipal/TabContainer/AbaDificuldade/LinhaTotalMonstrosValor
@onready var label_dano_player: Label = $VBoxContainerCentral/PainelPrincipal/TabContainer/AbaDificuldade/LinhaDanoPlayerValor

func _ready():
	get_tree().paused = true 
	
	# 1. Carrega os valores
	_carregar_configuracoes_globais()
	_carregar_configuracoes_gameplay()
	_carregar_configuracoes_dificuldade() # <--- NOVO
	
	# 2. Conecta os sinais
	_conectar_sinais_globais()
	_conectar_sinais_gameplay()
	_conectar_sinais_dificuldade() # <--- NOVO
	
	# 3. Conecta o botão de fechar/voltar
	botao_fechar.pressed.connect(_on_botao_fechar_pressed)
	
	# 4. Foca no primeiro elemento
	check_mostrar_log.call_deferred("grab_focus")

func _carregar_configuracoes_dificuldade():
	var config = ConfigManager.config_data
	
	# DIFICULDADE PROGRESSIVA (Checkbox)
	check_progressiva.button_pressed = config.dificuldade_progressiva
	
	# SELETOR DE PRESET (OptionButton)
	_setup_preset_options(config.current_preset_id)

func _setup_preset_options(current_preset_id: String):
	seletor_preset.clear()
	var selected_index = 0
	
	var presets_ids = ConfigManager.config_data.PRESETS.keys()
	
	for i in range(presets_ids.size()):
		var id = presets_ids[i]
		var titulo = ConfigManager.config_data.PRESETS[id].titulo
		
		seletor_preset.add_item(titulo, i)
		
		# Verifica qual ID é o atual
		if id == current_preset_id:
			selected_index = i
	
	seletor_preset.select(selected_index)
	# Força a atualização dos rótulos de leitura
	_atualizar_rotulos_preset(current_preset_id)

func _on_check_progressiva_toggled(button_pressed: bool):
	ConfigManager.set_global_value("dificuldade_progressiva", button_pressed)

func _on_seletor_preset_item_selected(index: int):
	var presets_ids = ConfigManager.config_data.PRESETS.keys()
	var new_preset_id = presets_ids[index]
	
	# 1. Salva o novo Preset ID
	ConfigManager.set_current_preset(new_preset_id) # Esta função já salva o ConfigManager
	
	# 2. Atualiza os rótulos de leitura
	_atualizar_rotulos_preset(new_preset_id)

func _atualizar_rotulos_preset(preset_id: String):
	var data = ConfigManager.config_data.PRESETS[preset_id]
	
	# Pega os multiplicadores para exibição
	var vida_monstro = data.multiplicador_vida_monstro
	var dano_monstro = data.multiplicador_dano_monstro
	var total_monstro = data.multiplicador_monstro_total
	var dano_player = data.multiplicador_dano_espada # Usa o dano da espada como referência
	
	# Atualiza os rótulos
	label_vida_monstro.text = "Vida Base dos Monstros: x%.1f" % vida_monstro
	label_dano_monstro.text = "Multiplicador de Dano Inimigo: x%.1f" % dano_monstro
	label_total_monstro.text = "Multiplicador de Inimigos/Onda: x%.1f" % total_monstro
	label_dano_player.text = "Multiplicador de Dano Player: x%.1f" % dano_player

func _conectar_sinais_dificuldade():
	check_progressiva.toggled.connect(_on_check_progressiva_toggled)
	seletor_preset.item_selected.connect(_on_seletor_preset_item_selected)

func _carregar_configuracoes_gameplay():
	var config = ConfigManager.config_data
	
	# VIDA BASE
	_setup_option_button(seletor_vida, VIDA_OPTIONS, config.base_vida_escolhida, "%s HP")
	
	# ENERGIA BASE
	_setup_option_button(seletor_energia, ENERGIA_OPTIONS, config.base_energia_escolhida, "%s Mana")
	
	# INICIA COM ENERGIA CARREGADA
	check_energia_carregada.button_pressed = config.inicia_com_energia
	
	# NÚMERO DE CURAS
	_setup_option_button(seletor_curas, CURAS_OPTIONS, config.base_cargas_cura_escolhida, "%s Cargas")
	
	# POTÊNCIA DE CURA
	_setup_option_button(seletor_potencia_cura, POTENCIA_CURA_OPTIONS, config.base_potencia_cura_escolhida, "+%s HP")

func _setup_option_button(button: OptionButton, options_array: Array, selected_index: int, format_string: String):
	button.clear()
	for i in range(options_array.size()):
		var value = options_array[i]
		var label_text = format_string % value
		button.add_item(label_text, i)
	button.select(selected_index)

func _conectar_sinais_gameplay():
	
	seletor_vida.item_selected.connect(_on_seletor_vida_player_item_selected)
	seletor_energia.item_selected.connect(_on_seletor_energia_player_item_selected)
	check_energia_carregada.toggled.connect(_on_check_energia_carregada_toggled)
	seletor_curas.item_selected.connect(_on_seletor_numero_curas_item_selected)
	seletor_potencia_cura.item_selected.connect(_on_seletor_potencia_cura_item_selected)

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
		# ⚠️ CORREÇÃO: Usamos get_tree().change_scene_to_file para garantir que
		# a troca de cena seja feita de forma limpa, substituindo a raiz.
		get_tree().change_scene_to_file(CENA_TELA_INICIAL.scene_file_path)
	else:
		push_error("Cena da Tela Inicial não carregada!")

	# 3. Destrói a si mesmo (a tela de configuração)
	# (NOTA: O change_scene_to_file já destrói a cena antiga, mas
	# como esta é uma CanvasLayer adicionada, a destruição explícita é mais segura.)
	queue_free()
	# 1. Despausa o jogo
	get_tree().paused = false
	
	# 2. Carrega a tela inicial
	if CENA_TELA_INICIAL != null:
		get_tree().change_scene_to_file(CENA_TELA_INICIAL.scene_file_path)
	else:
		push_error("Cena da Tela Inicial não carregada!")

	# 3. Destrói a si mesmo (a tela de configuração)
	queue_free()

func _on_seletor_vida_player_item_selected(index: int):
	ConfigManager.set_global_value("base_vida_escolhida", index)
	
func _on_seletor_energia_player_item_selected(index: int):
	ConfigManager.set_global_value("base_energia_escolhida", index)

func _on_check_energia_carregada_toggled(button_pressed: bool):
	ConfigManager.set_global_value("inicia_com_energia", button_pressed)
	
func _on_seletor_numero_curas_item_selected(index: int):
	ConfigManager.set_global_value("base_cargas_cura_escolhida", index)

func _on_seletor_potencia_cura_item_selected(index: int):
	ConfigManager.set_global_value("base_potencia_cura_escolhida", index)	
