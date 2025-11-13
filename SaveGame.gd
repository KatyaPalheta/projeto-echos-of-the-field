# [Script: SaveGame.gd]
# (Versão com a nova gaveta 'bonus_foco_leque')
extends Resource
class_name SaveGame 

@export var tempo_total_gasto: float = 0.0
@export var onda_mais_alta_salva: int = 1 
@export var personagem_escolhido: String = "Heroina" 

# --- NOSSAS "GAVETAS" DE UPGRADES ---

# --- Bônus Táticos (Tipo "unico") ---
@export var conserva_energia_entre_ondas: bool = false
@export var energia_atual_salva: float = 0.0 

# --- Bônus de Habilidade (Contadores) ---
@export var bonus_rajada_flechas: int = 0
@export var bonus_leque_misseis: int = 0

# --- Bônus Acumulativos (Tipo "stack") ---
@export var bonus_vida_maxima: float = 0.0
@export var bonus_energia_maxima: float = 0.0
@export var bonus_velocidade_movimento: float = 0.0
@export var bonus_reducao_dano: float = 0.0 

@export var bonus_potencia_cura: float = 0.0
@export var bonus_cura_por_morte: float = 0.0
@export var bonus_cargas_cura: int = 0 

@export var bonus_dano_espada: float = 0.0
@export var bonus_dano_espada_especial: float = 0.0

@export var bonus_cadencia_arco: float = 0.0
@export var bonus_cadencia_magia: float = 0.0
@export var bonus_eficiencia_energia: float = 0.0

# --- ADIÇÃO DA NOVA GAVETA ---
@export var bonus_foco_leque: float = 0.0 # (Em graus)
