extends CanvasLayer

# Ajuste este caminho para o seu botão "Continuar"
# O seu print mostra 'VBoxContainer/TextureButton', então está certo!
@onready var continue_button: TextureButton = $VBoxContainer/TextureButton

# Variável de controle para o "truque"
var can_close: bool = false

func _ready():
	# 1. PAUSA O JOGO
	get_tree().paused = true
	
	# 2. FOCA O BOTÃO PARA O CONTROLE
	if continue_button != null:
		continue_button.grab_focus()
	
	# 3. O "TRUQUE": Espera 0.2s antes de permitir fechar o menu
	# Isso "consome" o input 'ui_accept' que abriu o menu
	await get_tree().create_timer(0.2).timeout
	can_close = true

# (A função _unhandled_input que checava "ui_cancel" foi REMOVIDA!
#  Não precisamos dela, o 'grab_focus()' já cuida do 'ui_accept'.)

# Esta função é conectada ao sinal "pressed()" do seu TextureButton
func _on_continue_button_pressed():
	# Só fecha se o timer de 0.2s já acabou
	if not can_close:
		return
		
	_close_menu()

# Esta função fecha o menu
func _close_menu():
	get_tree().paused = false
	queue_free()
