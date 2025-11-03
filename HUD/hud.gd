extends CanvasLayer

# Pega as referências das três barras
@onready var barra_vida: TextureProgressBar = $BarraVida
@onready var barra_energia: TextureProgressBar = $BarraEnergia
@onready var onda_label: Label = $OndaLabel
@onready var onda_timer: Timer = $OndaTimer

@onready var vida_label: Label = $VidaLabel

# --- NOVO! A REFERÊNCIA QUE FALTAVA ---
@onready var energia_label: Label = $EnergiaLabel 
# (Baseado no seu print 'image_23a_f0.png', o nome do nó é esse!)

@onready var log_container: VBoxContainer = $LogContainer
@onready var contador_label: Label = $ContadorLabel

@onready var estrela1: TextureRect = $CargasCuraContainer/Estrela1
@onready var estrela2: TextureRect = $CargasCuraContainer/Estrela2
@onready var estrela3: TextureRect = $CargasCuraContainer/Estrela3

@export var tex_estrela_cheia: Texture2D
@export var tex_estrela_vazia: Texture2D

func _ready():
	Logger.log_updated.connect(_on_log_updated)
	GameManager.stats_atualizadas.connect(atualizar_contador_inimigos)

func atualizar_vida(vida_atual: float, vida_maxima: float) -> void:
	barra_vida.max_value = vida_maxima
	vida_label.text = str(int(vida_atual))
	barra_vida.value = vida_atual

# --- FUNÇÃO ATUALIZADA ---
func atualizar_energia(energia_atual: float, energia_maxima: float):
	barra_energia.max_value = energia_maxima
	energia_label.text = str(int(energia_atual))
	barra_energia.value = energia_atual

# (A função 'atualizar_mana' foi removida, já que não temos mais a BarraMana)

func _on_log_updated(messages: Array[String]):
	for child in log_container.get_children():
		child.queue_free()
	for msg in messages:
		var new_label = Label.new()
		new_label.text = msg
		# (Opcional: Adicione um LabelSettings aqui para a fonte ficar pixelada)
		log_container.add_child(new_label)

func atualizar_cargas_cura(cargas_restantes: int):
	estrela1.texture = tex_estrela_cheia if cargas_restantes >= 1 else tex_estrela_vazia
	estrela2.texture = tex_estrela_cheia if cargas_restantes >= 2 else tex_estrela_vazia
	estrela3.texture = tex_estrela_cheia if cargas_restantes == 3 else tex_estrela_vazia

# --- FUNÇÃO ATUALIZADA COM A LÓGICA DO "ONDA LABEL" ---
func atualizar_contador_inimigos(mortos: int, total: int, _onda: int):
	
	# 1. O código que você já tem (para o "0 / 10")
	contador_label.text = "%s / %s" % [mortos, total] # (Ou como você ajustou!)

	# --- NOSSA NOVA LÓGICA DE FEEDBACK! ---
	# Se 'mortos' é 0, significa que a onda ACABOU de começar!
	if mortos == 0:
		
		# Define o texto do label (usando o parâmetro _onda!)
		onda_label.text = "Onda %s" % _onda
		
		# Mostra o label
		onda_label.visible = true
		
		# Inicia o timer de 3 segundos
		onda_timer.start()

func _on_onda_timer_timeout() -> void:
	# Esconde o label "Onda X"
	onda_label.visible = false
