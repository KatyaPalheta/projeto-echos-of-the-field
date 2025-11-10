# [Script: transicao_onda.gd]
# (Versão final com a lógica do Seletor)
extends CanvasLayer

# --- Referências dos Nós (corrigidas para sua árvore) ---
@onready var label_onda_num: Label = $VBoxContainer/AnimationPlayer/LabelOndaNum
@onready var label_tempo_onda: Label = $VBoxContainer/LabelTempoOnda
@onready var label_tempo_total: Label = $VBoxContainer/LabelTempoTotal

@onready var botao_continuar: TextureButton = $VBoxContainer/BotaoContinuar
@onready var botao_reiniciar: TextureButton = $VBoxContainer/BotaoReiniciar
@onready var botao_sair: TextureButton = $VBoxContainer/BotaoSair

@onready var anim_player: AnimationPlayer = $VBoxContainer/AnimationPlayer

# --- NOVAS REFERÊNCIAS (Os Seletores!) ---
@onready var seletor_continuar: NinePatchRect = $VBoxContainer/BotaoContinuar/Seletor
@onready var seletor_reiniciar: NinePatchRect = $VBoxContainer/BotaoReiniciar/Seletor
@onready var seletor_sair: NinePatchRect = $VBoxContainer/BotaoSair/Seletor
# --- FIM DAS NOVAS ---

func _ready():
	get_tree().paused = true
	
	# --- CONECTANDO SINAIS (A MÁGICA!) ---
	botao_continuar.pressed.connect(_on_botao_continuar_pressed)
	botao_continuar.focus_entered.connect(_on_BotaoContinuar_focus_entered)
	botao_continuar.focus_exited.connect(_on_BotaoContinuar_focus_exited)
	
	botao_reiniciar.pressed.connect(_on_botao_reiniciar_pressed)
	botao_reiniciar.focus_entered.connect(_on_BotaoReiniciar_focus_entered)
	botao_reiniciar.focus_exited.connect(_on_BotaoReiniciar_focus_exited)
	
	botao_sair.pressed.connect(_on_botao_sair_pressed)
	botao_sair.focus_entered.connect(_on_BotaoSair_focus_entered)
	botao_sair.focus_exited.connect(_on_BotaoSair_focus_exited)
	# --- FIM DAS CONEXÕES ---
	
	if anim_player != null and anim_player.has_animation("pulsar"):
		anim_player.play("pulsar")
	
	# O "call_deferred" do Checklist 3!
	botao_continuar.call_deferred("grab_focus")

# (Função setup() continua igual...)
func setup(numero_onda_atual: int, tempo_gasto_na_onda: float):
	label_onda_num.text = "Onda %s Concluída!" % numero_onda_atual
	label_tempo_onda.text = "Onda: %s" % _formatar_tempo(tempo_gasto_na_onda)
	label_tempo_total.text = "Partida: %s" % SaveManager.get_tempo_total_formatado()
	
	SaveManager.dados_atuais.onda_mais_alta_salva = max(
		SaveManager.dados_atuais.onda_mais_alta_salva, 
		numero_onda_atual + 1
	)
	SaveManager.salvar_dados()

# (Funções dos botões [pressed] continuam iguais...)
func _on_botao_continuar_pressed():
	get_tree().paused = false
	GameManager.avancar_para_proxima_onda()
	queue_free() 

func _on_botao_reiniciar_pressed():
	get_tree().paused = false
	
	# 1. Atualiza o Save (como antes)
	if SaveManager.dados_atuais != null:
		SaveManager.dados_atuais.onda_mais_alta_salva = 1
		SaveManager.salvar_dados()
		
	# --- A CORREÇÃO DO BUG AQUI! ---
	# 2. ATUALIZA A MEMÓRIA! (Diz ao GameManager para voltar ao 0)
	GameManager.onda_atual_index = 0
	# --- FIM DA CORREÇÃO ---
		
	get_tree().change_scene_to_file(get_tree().current_scene.scene_file_path)

func _on_botao_sair_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://cenas/tela_inicial.tscn")

# (Função _formatar_tempo() continua igual...)
func _formatar_tempo(tempo_em_segundos: float) -> String:
	var tempo_float: float = tempo_em_segundos
	var minutos = int(floor(tempo_float / 60.0))
	var segundos = int(fmod(tempo_float, 60.0))
	return "%02d:%02d" % [minutos, segundos]

# --- NOSSAS NOVAS FUNÇÕES DE LIGA/DESLIGA O SELETOR ---

func _on_BotaoContinuar_focus_entered():
	seletor_continuar.visible = true
func _on_BotaoContinuar_focus_exited():
	seletor_continuar.visible = false

func _on_BotaoReiniciar_focus_entered():
	seletor_reiniciar.visible = true
func _on_BotaoReiniciar_focus_exited():
	seletor_reiniciar.visible = false

func _on_BotaoSair_focus_entered():
	seletor_sair.visible = true
func _on_BotaoSair_focus_exited():
	seletor_sair.visible = false
