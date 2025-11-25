# [Script: Configuracoes.gd]
extends Resource
class_name Configuracoes

# --- CONFIGURAÇÕES GLOBAIS (Salvas FORA do Preset de Dificuldade) ---
@export var mostrar_log: bool = true
@export_range(0.0, 1.0, 0.1) var volume_master: float = 1.0
@export_range(1, 20, 1, "suffix: Ondas") var numero_de_ondas_max: int = 12
@export_range(0.5, 3.0, 0.1) var zoom_camera: float = 1.0
@export var base_vida_escolhida: int = 0      # 0 = 100, 1 = 200, etc.
@export var base_energia_escolhida: int = 0   # 0 = 100, 1 = 200, etc.
@export var inicia_com_energia: bool = false
@export var base_cargas_cura_escolhida: int = 0 # 0 = 3, 1 = 6, 2 = 9
@export var base_potencia_cura_escolhida: int = 0 # 0 = 25, 1 = 50, 2 = 100

# --- SELETOR DE PRESET ATUAL ---
@export var current_preset_id: String = "normal" 

# --- CONFIGURAÇÕES DE GAMEPLAY ---
# Se for TRUE, as stats do inimigo serão multiplicadas pelo índice da onda
@export var dificuldade_progressiva: bool = false 

const PRESETS = {
	"facil": {
		"titulo": "Aventura Leve (x0.7)",
		# Stats Base Player (Permanecem aqui, mesmo que o player possa mudar com os seletores)
		"vida_base_player": 200.0,
		"energia_base_player": 150.0,
		"cargas_cura_base": 4, 
		# Multiplicadores de Dificuldade
		"multiplicador_dano_arco": 1.2, # Player Buffed
		"multiplicador_dano_espada": 1.2,
		"multiplicador_dano_magia": 1.2,
		"multiplicador_monstro_total": 0.7,
		"multiplicador_dano_monstro": 0.7,
		"multiplicador_vida_monstro": 0.7,
	},
	"normal": {
		"titulo": "Desafio Padrão (x1.0)",
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
	"dificil": {
		"titulo": "Desafio Brutal (x2.0)",
		"vida_base_player": 75.0,
		"energia_base_player": 80.0,
		"cargas_cura_base": 3,
		"multiplicador_dano_arco": 0.8, # Player Debuffed
		"multiplicador_dano_espada": 0.8,
		"multiplicador_dano_magia": 0.8,
		"multiplicador_monstro_total": 2.0,
		"multiplicador_dano_monstro": 2.0,
		"multiplicador_vida_monstro": 2.0,
	},
	"lucas": {
		"titulo": "Modo Lucas Jogando God of War (x4.0)",
		"vida_base_player": 50.0,
		"energia_base_player": 50.0,
		"cargas_cura_base": 2, 
		"multiplicador_dano_arco": 0.5, # Player Severely Debuffed
		"multiplicador_dano_espada": 0.5,
		"multiplicador_dano_magia": 0.5,
		"multiplicador_monstro_total": 4.0,
		"multiplicador_dano_monstro": 4.0,
		"multiplicador_vida_monstro": 4.0,
	}
}
