# [Script: SaveGame.gd]
extends Resource
class_name SaveGame # <-- Isso "ensina" o Godot a reconhecer o "tipo" SaveGame

# --- DADOS PERSISTENTES (EXISTENTES) ---

# O cronômetro total que você pediu
@export var tempo_total_gasto: float = 0.0

# Onde o jogador parou
@export var onda_mais_alta_salva: int = 1 # (Começa na 1)

# Futuro (US-70: Skins)
@export var personagem_escolhido: String = "Heroina" 

# --- NOSSAS NOVAS "GAVETAS" DE UPGRADES ---

# --- Bônus Táticos (Tipo "unico") ---
@export var conserva_energia_entre_ondas: bool = false # (Já existia) [cite: 18]

# --- Bônus de Habilidade (Tipo "habilidade") ---
@export var tem_upgrade_rajada_flechas: bool = false
@export var tem_upgrade_leque_misseis: bool = false
# (Adicione outros 'tem_upgrade_...' aqui)

# --- Bônus Acumulativos (Tipo "stack") ---
@export var bonus_vida_maxima: float = 0.0
@export var bonus_energia_maxima: float = 0.0
@export var bonus_velocidade_movimento: float = 0.0

@export var bonus_potencia_cura: float = 0.0
@export var bonus_cura_por_morte: float = 0.0
@export var bonus_cargas_cura: int = 0 # (Usado para o 'unico' de cargas de cura)

@export var bonus_dano_espada: float = 0.0
@export var bonus_dano_espada_especial: float = 0.0

@export var bonus_cadencia_arco: float = 0.0
@export var bonus_cadencia_magia: float = 0.0

# (Adicione outros 'bonus_...' aqui, ex: bonus_dano_critico)
