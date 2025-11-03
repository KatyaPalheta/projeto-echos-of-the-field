extends CanvasLayer

# Pega as referências das três barras
@onready var barra_vida: TextureProgressBar = $BarraVida
@onready var barra_energia: TextureProgressBar = $BarraEnergia

@onready var vida_label: Label = $VidaLabel

# --- NOVO! A REFERÊNCIA QUE FALTAVA ---
@onready var energia_label: Label = $EnergiaLabel 
# (Baseado no seu print 'image_23a0f0.png', o nome do nó é esse!)

@onready var log_container: VBoxContainer = $LogContainer

@onready var estrela1: TextureRect = $CargasCuraContainer/Estrela1
@onready var estrela2: TextureRect = $CargasCuraContainer/Estrela2
@onready var estrela3: TextureRect = $CargasCuraContainer/Estrela3

@export var tex_estrela_cheia: Texture2D
@export var tex_estrela_vazia: Texture2D

func _ready():
	Logger.log_updated.connect(_on_log_updated)

func atualizar_vida(vida_atual: float, vida_maxima: float) -> void:
	barra_vida.max_value = vida_maxima
	vida_label.text = str(int(vida_atual))
	barra_vida.value = vida_atual

# --- FUNÇÃO ATUALIZADA ---
func atualizar_energia(energia_atual: float, energia_maxima: float):
	barra_energia.max_value = energia_maxima
	
	# --- NOVO! A LINHA QUE FALTAVA ---
	energia_label.text = str(int(energia_atual))
	
	barra_energia.value = energia_atual


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
