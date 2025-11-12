# [Script: SaveGame.gd]
extends Resource
class_name SaveGame # <-- Isso "ensina" o Godot a reconhecer o "tipo" SaveGame

# --- NOSSOS DADOS PERSISTENTES ---

# O cronômetro total que você pediu
@export var tempo_total_gasto: float = 0.0

# Onde o jogador parou
@export var onda_mais_alta_salva: int = 1 # (Começa na 1)

# Futuro (US-70: Skins)
@export var personagem_escolhido: String = "Heroina" 

# --- FUTURAS "GAVETAS" (Upgrades) ---
# (A gente pode adicionar isso depois, quando for fazer os upgrades)
@export var conserva_energia_entre_ondas: bool = false
# @export var bonus_vida_maxima: float = 0.0
# @export var bonus_energia_maxima: float = 0.0
# @export var bonus_cargas_cura: int = 0
