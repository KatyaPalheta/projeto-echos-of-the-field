# [Script: IconeSkill.gd]
extends PanelContainer

@onready var icone: TextureRect = $Fundo/Icone
@onready var contador_label: Label = $Fundo/Icone/Contador

# Guarda qual upgrade este slot está mostrando
var id_upgrade_atual: String = ""

func _ready():
	# Garante que ele começa escondido
	visible = false

# Função principal: Configura o slot pela primeira vez
func setup_slot(id_upgrade: String):
	id_upgrade_atual = id_upgrade
	
	var dados_db = UpgradeDatabase.get_upgrade_data(id_upgrade)
	if dados_db.is_empty():
		push_warning("IconeSkill: Não achei dados para o ID: %s" % id_upgrade)
		return

	# Carrega o ícone
	if dados_db.has("icone_path"):
		icone.texture = load(dados_db.icone_path)
		
	# Adiciona a "dica" (tooltip) ao passar o mouse
	var titulo = dados_db.get("titulo", "??")
	var descricao = dados_db.get("descricao", "...")
	tooltip_text = "[font_size=18]%s[/font_size]\n%s" % [titulo, descricao]
	
	# Atualiza o contador (vai mostrar 1 pela primeira vez)
	atualizar_contador(1)
	
	# REVELA O SLOT!
	visible = true

# Atualiza o texto do contador (x2, x3, etc.)
func atualizar_contador(contador: int):
	if contador > 1:
		contador_label.text = "x%s" % contador
		contador_label.visible = true
	else:
		# Não mostra "x1"
		contador_label.visible = false

# Usado para resetar a HUD na Onda 1
func resetar_slot():
	visible = false
	id_upgrade_atual = ""
	tooltip_text = ""
	icone.texture = null
	contador_label.visible = false
