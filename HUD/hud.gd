extends CanvasLayer

# Pega as referências das três barras
@onready var barra_vida: TextureProgressBar = $BarraVida
@onready var barra_energia: TextureProgressBar = $BarraEnergia
@onready var barra_mana: TextureProgressBar = $BarraMana

@onready var vida_label: Label = $VidaLabel

# Esta é a função que o player vai chamar.
# Ela vai receber a vida direto do HealthComponent.
func atualizar_vida(vida_atual: float, vida_maxima: float) -> void:
	
	# Garante que a barra saiba qual é o máximo
	barra_vida.max_value = vida_maxima
	vida_label.text = str(int(vida_atual))
	# Atualiza o valor (o preenchimento) da barra
	barra_vida.value = vida_atual

# --- FUNÇÕES FUTURAS (Prontas para quando precisarmos) ---

# (Ainda não temos um "EnergyComponent", mas quando tivermos,
#  vamos chamar esta função)
func atualizar_energia(energia_atual: float, energia_maxima: float) -> void:
	barra_energia.max_value = energia_maxima
	barra_energia.value = energia_atual

# (Ainda não temos um "ManaComponent", mas quando tivermos,
#  vamos chamar esta função)
func atualizar_mana(mana_atual: float, mana_maxima: float) -> void:
	barra_mana.max_value = mana_maxima
	barra_mana.value = mana_atual
