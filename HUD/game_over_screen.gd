extends CanvasLayer

# (Confirme se este caminho está certo!)
@onready var first_button: TextureButton = $VBoxContainer/TextureButton

# Esta função roda assim que a tela de Game Over aparece
func _ready():
	
	# 1. Foca o botão para o controle (isso ainda está certo)
	if first_button != null:
		first_button.grab_focus()
	
	# 2. NÃO PAUSA AINDA!
	#    Em vez disso, espera 2.0 segundos (o tempo do zoom/fuga)
	await get_tree().create_timer(2.0).timeout
	
	# 3. AGORA SIM: Pausa o jogo, depois que o drama acabou!
	get_tree().paused = true

# Esta é a sua função conectada ao sinal 'pressed()' do botão
func _on_texture_button_pressed(): # (O NOME PODE SER DIFERENTE!)
	
	get_tree().paused = false
	
	# 1. Atualiza o Save (como antes)
	if SaveManager.dados_atuais != null:
		SaveManager.dados_atuais.onda_mais_alta_salva = 1
		SaveManager.salvar_dados()
		
	# --- A CORREÇÃO DO BUG AQUI! ---
	# 2. ATUALIZA A MEMÓRIA!
	GameManager.onda_atual_index = 0
	# --- FIM DA CORREÇÃO ---

	get_tree().reload_current_scene()
