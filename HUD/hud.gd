extends CanvasLayer

# Pega as referências das três barras
@onready var barra_vida: TextureProgressBar = $BarraVida
@onready var barra_energia: TextureProgressBar = $BarraEnergia
@onready var barra_mana: TextureProgressBar = $BarraMana

@onready var vida_label: Label = $VidaLabel

@onready var log_container: VBoxContainer = $LogContainer

# --- ADIÇÃO 1: A FUNÇÃO _READY() QUE FALTAVA ---
func _ready():
	# Conecta esta cena ao sinal do nosso Autoload "Logger"
	# (O 'Logger' já existe globalmente porque o registramos)
	Logger.log_updated.connect(_on_log_updated)
# --- FIM DA ADIÇÃO ---


# Esta é a função que o player vai chamar.
# Ela vai receber a vida direto do HealthComponent.
func atualizar_vida(vida_atual: float, vida_maxima: float) -> void:
	
	# Garante que a barra saiba qual é o máximo
	barra_vida.max_value = vida_maxima
	vida_label.text = str(int(vida_atual))
	# Atualiza o valor (o preenchimento) da barra
	barra_vida.value = vida_atual

# --- FUNÇÕES FUTURAS (Prontas para quando precisarmos) ---
# ... (suas funções de atualizar_energia e atualizar_mana ficam aqui) ...
func atualizar_energia(energia_atual: float, energia_maxima: float) -> void:
	barra_energia.max_value = energia_maxima
	barra_energia.value = energia_atual

func atualizar_mana(mana_atual: float, mana_maxima: float) -> void:
	barra_mana.max_value = mana_maxima
	barra_mana.value = mana_atual

# --- ADIÇÃO 2: A NOVA FUNÇÃO QUE RECEBE O LOG ---
# Esta função é chamada pelo SINAL do Logger
func _on_log_updated(messages: Array[String]):
	
	# 1. Limpa o log antigo (remove todos os Labels antigos)
	for child in log_container.get_children():
		child.queue_free()
		
	# 2. Cria os novos labels (o array já vem na ordem certa: do topo para baixo)
	for msg in messages:
		var new_label = Label.new()
		new_label.text = msg
		# (Opcional: Adicione um LabelSettings aqui para a fonte ficar pixelada)
		log_container.add_child(new_label)
