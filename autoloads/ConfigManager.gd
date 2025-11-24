# [Script: ConfigManager.gd]
extends Node

# O caminho onde vamos salvar as configurações
const CONFIG_PATH = "user://config.tres"
const ZOOM_OPTIONS: Array[float] = [3.0, 2.0, 1.0, 0.5] 
const VIDA_OPTIONS: Array[float] = [100.0, 200.0, 300.0, 400.0]
const ENERGIA_OPTIONS: Array[float] = [100.0, 200.0, 300.0, 400.0]
const CURAS_OPTIONS: Array[int] = [3, 6, 9]
const POTENCIA_CURA_OPTIONS: Array[float] = [25.0, 50.0, 100.0]
# A instância viva do nosso Resource de Configurações
var config_data: Configuracoes
const CONFIG_RESOURCE = preload("res://autoloads/Configuracoes.gd")

func _ready():
	carregar_configuracoes()
	Logger.log("ConfigManager pronto. Preset atual: %s" % config_data.current_preset_id)

# --- FUNÇÕES INTERNAS DO GODOT ---

func carregar_configuracoes():
	if ResourceLoader.exists(CONFIG_PATH):
		config_data = ResourceLoader.load(CONFIG_PATH)
		Logger.log("Configurações carregadas do disco!")
	else:
		Logger.log("Nenhuma configuração encontrada. Criando uma nova.")
		# Cria a instância do Resource usando o CONSTANTE preloaded
		config_data = CONFIG_RESOURCE.new() 
		salvar_configuracoes()

func salvar_configuracoes():
	if config_data == null:
		Logger.log("[ERRO] Tentativa de salvar Configurações nulas!")
		return
		
	var erro = ResourceSaver.save(config_data, CONFIG_PATH)
	if erro == OK:
		Logger.log("Configurações salvas com sucesso em: %s" % CONFIG_PATH)
	else:
		Logger.log("[ERRO] FALHA AO SALVAR AS CONFIGURAÇÕES! Código: %s" % erro)

# --- FUNÇÕES PÚBLICAS PARA USO NO JOGO ---

# Retorna o valor de uma variável de configuração de Gameplay
func get_gameplay_value(key: String):
	var preset_id = config_data.current_preset_id
	
	# 1. Pega os dados do preset atual (ex: "normal")
	if not config_data.PRESETS.has(preset_id):
		push_warning("ConfigManager: ID de Preset não encontrado: %s" % preset_id)
		# Se não encontrar, tenta voltar para o padrão "normal"
		preset_id = "normal"
		if not config_data.PRESETS.has(preset_id):
			return null # Falha catastrófica

	var current_preset_data = config_data.PRESETS[preset_id]
	
	# 2. Retorna o valor da chave (ex: "multiplicador_dano_arco")
	if current_preset_data.has(key):
		return current_preset_data[key]
		
	push_warning("ConfigManager: Chave '%s' não encontrada no Preset '%s'" % [key, preset_id])
	return null

# Função para a tela de configurações chamar e mudar o preset
func set_current_preset(new_id: String):
	if config_data.PRESETS.has(new_id):
		config_data.current_preset_id = new_id
		salvar_configuracoes()
		Logger.log("Preset de dificuldade alterado para: %s" % new_id)
		return true
	push_warning("ConfigManager: Tentativa de setar Preset inválido: %s" % new_id)
	return false
# [Em: ConfigManager.gd]
# (SUBSTITUA ESTA FUNÇÃO set_global_value INTEIRA)

func set_global_value(key: String, value):
	
	# ⚠️ SOLUÇÃO FINAL (Usando a lista de propriedades)
	var property_exists = false
	var property_list = config_data.get_property_list()
	
	# Percorre a lista de propriedades que o Godot EXPORTA
	for p in property_list:
		if p.name == key:
			property_exists = true
			break
	
	if property_exists:
		# Define o valor usando o método set nativo (que não causa erro)
		config_data.set(key, value)
		
		salvar_configuracoes()
		Logger.log("Configuração Global '%s' alterada para: %s" % [key, value])
		return true
	else:
		# Se a propriedade não foi encontrada na lista (erro de digitação)
		push_warning("ConfigManager: Tentativa de setar Global inválida: %s" % key)
		return false
