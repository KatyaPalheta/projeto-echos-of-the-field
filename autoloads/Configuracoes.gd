# [Script: Configuracoes.gd]
extends Resource
class_name Configuracoes

# --- CONFIGURAÇÕES GLOBAIS (Salvas FORA do Preset de Dificuldade) ---
@export var mostrar_log: bool = true
@export_range(0.0, 1.0, 0.1) var volume_master: float = 1.0
@export_range(1, 20, 1, "suffix: Ondas") var numero_de_ondas_max: int = 12
@export_range(1.0, 3.0, 0.1) var zoom_camera: float = 1.0 

# --- SELETOR DE PRESET ATUAL ---
@export var current_preset_id: String = "normal" 

# --- CONFIGURAÇÕES DE GAMEPLAY ---
# Se for TRUE, as stats do inimigo serão multiplicadas pelo índice da onda
@export var dificuldade_progressiva: bool = false 

# --- DICIONÁRIO DE PRESETS DE DIFICULDADE (Onde a mágica acontece) ---
# O método é definido aqui, e os valores são lidos pelo ConfigManager
const PRESETS = {
	"facil": {
		"titulo": "Aventura Leve",
		"vida_base_player": 200.0,
		"energia_base_player": 150.0,
		"cargas_cura_base": 4, 
		"multiplicador_dano_arco": 1.2,
		"multiplicador_dano_espada": 1.2,
		"multiplicador_dano_magia": 1.2,
		"multiplicador_monstro_total": 0.5,
		"multiplicador_dano_monstro": 0.8,
		"multiplicador_vida_monstro": 0.8,
	},
	"normal": {
		"titulo": "Desafio Padrão",
		"vida_base_player": 100.0,
		"energia_base_player": 100.0,
		"cargas_cura_base": 3,
		"multiplicador_dano_arco": 1.0,
		"multiplicador_dano_espada": 1.0,
		"multiplicador_dano_magia": 1.0,
		"multiplicador_monstro_total": 1.0,
		"multiplicador_dano_monstro": 1.0,
		"multiplicador_vida_monstro": 1.0,
	},
	"lucas": {
		"titulo": "Modo God of War",
		"vida_base_player": 50.0,
		"energia_base_player": 50.0,
		"cargas_cura_base": 2, 
		"multiplicador_dano_arco": 0.7,
		"multiplicador_dano_espada": 0.7,
		"multiplicador_dano_magia": 0.7,
		"multiplicador_monstro_total": 2.0,
		"multiplicador_dano_monstro": 1.5,
		"multiplicador_vida_monstro": 2.0,
	},
	# Adicione mais presets aqui (ex: "muito_dificil")
}
