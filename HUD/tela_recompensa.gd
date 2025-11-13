# [Script: TelaRecompensa.gd]
# (Versão CORRIGIDA com o "s" em NichosContainer)
extends CanvasLayer

# --- Referências dos 3 Nichos (Caminhos Corrigidos) ---
# Adicionado o "s" em NichosContainer em todas as linhas abaixo
@onready var nicho1: TextureButton = $ColorRect/Painel/VBoxContainer/NichosContainer/Nicho1
@onready var icone1: TextureRect = $ColorRect/Painel/VBoxContainer/NichosContainer/Nicho1/VBoxContainer/Icone1
@onready var titulo1: Label = $ColorRect/Painel/VBoxContainer/NichosContainer/Nicho1/VBoxContainer/Titulo1
@onready var seletor1: NinePatchRect = $ColorRect/Painel/VBoxContainer/NichosContainer/Nicho1/Seletor

@onready var nicho2: TextureButton = $ColorRect/Painel/VBoxContainer/NichosContainer/Nicho2
@onready var icone2: TextureRect = $ColorRect/Painel/VBoxContainer/NichosContainer/Nicho2/VBoxContainer/Icone2
@onready var titulo2: Label = $ColorRect/Painel/VBoxContainer/NichosContainer/Nicho2/VBoxContainer/Titulo2
@onready var seletor2: NinePatchRect = $ColorRect/Painel/VBoxContainer/NichosContainer/Nicho2/Seletor

@onready var nicho3: TextureButton = $ColorRect/Painel/VBoxContainer/NichosContainer/Nicho3
@onready var icone3: TextureRect = $ColorRect/Painel/VBoxContainer/NichosContainer/Nicho3/VBoxContainer/Icone3
@onready var titulo3: Label = $ColorRect/Painel/VBoxContainer/NichosContainer/Nicho3/VBoxContainer/Titulo3
@onready var seletor3: NinePatchRect = $ColorRect/Painel/VBoxContainer/NichosContainer/Nicho3/Seletor
# --- Fim da Correção ---

# --- Referências Gerais (Caminhos Corretos) ---
@onready var descricao_label: Label = $ColorRect/Painel/VBoxContainer/BannerDescricao/VBoxContainer/DescricaoLabel

# Guarda os 3 IDs (ex: "upgrade_vida_maxima") que estamos mostrando
var upgrades_oferecidos: Array = []

func _ready():
	# 1. Pausa o jogo (a tela de transição já deve ter pausado, mas garantimos)
	get_tree().paused = true
	
	# 2. Conecta todos os sinais
	# (Note que usamos .bind() para passar o índice do nicho)
	nicho1.pressed.connect(_on_nicho_pressed.bind(0))
	nicho1.focus_entered.connect(_on_nicho_focus_entered.bind(0))
	nicho1.focus_exited.connect(_on_nicho_focus_exited.bind(0))
	
	nicho2.pressed.connect(_on_nicho_pressed.bind(1))
	nicho2.focus_entered.connect(_on_nicho_focus_entered.bind(1))
	nicho2.focus_exited.connect(_on_nicho_focus_exited.bind(1))

	nicho3.pressed.connect(_on_nicho_pressed.bind(2))
	nicho3.focus_entered.connect(_on_nicho_focus_entered.bind(2))
	nicho3.focus_exited.connect(_on_nicho_focus_exited.bind(2))
	
	# 3. Busca os upgrades e preenche a tela
	_setup_tela()
	
	# 4. Foca no primeiro nicho
	nicho1.call_deferred("grab_focus")

# --- Funções de Setup ---

func _setup_tela():
	# 1. Pede 3 upgrades aleatórios ao nosso "Cérebro"
	upgrades_oferecidos = UpgradeDatabase.get_random_upgrades(3)
	
	# 2. Se não houver mais upgrades no pool (ex: jogador pegou tudo)
	if upgrades_oferecidos.is_empty():
		Logger.log("Não há mais upgrades disponíveis. Avançando automaticamente.")
		_avancar_e_fechar() # Apenas avança, sem aplicar bônus
		return

	# 3. Preenche cada nicho com os dados
	_preencher_nicho(0, nicho1, icone1, titulo1)
	_preencher_nicho(1, nicho2, icone2, titulo2)
	_preencher_nicho(2, nicho3, icone3, titulo3)

# Helper para popular os dados de UM nicho
func _preencher_nicho(index: int, botao: TextureButton, icone: TextureRect, titulo: Label):
	# Se o Database nos deu menos de 3 upgrades (ex: só tinha 2 sobrando)
	if index >= upgrades_oferecidos.size():
		botao.visible = false # Esconde o nicho
		return
		
	botao.visible = true
	var upgrade_id = upgrades_oferecidos[index]
	var data = UpgradeDatabase.get_upgrade_data(upgrade_id)
	
	if data.is_empty():
		botao.visible = false
		return
		
	titulo.text = data.titulo
	icone.texture = load(data.icone_path)


# --- Funções de UI (Foco e Seleção) ---

func _on_nicho_focus_entered(index: int):
	# Se o nicho estiver invisível (menos de 3 upgrades), não faz nada
	if index >= upgrades_oferecidos.size():
		return
		
	var upgrade_id = upgrades_oferecidos[index]
	var data = UpgradeDatabase.get_upgrade_data(upgrade_id)
	
	# Mostra o seletor correto e atualiza a descrição
	match index:
		0: seletor1.visible = true
		1: seletor2.visible = true
		2: seletor3.visible = true
			
	descricao_label.text = data.descricao

func _on_nicho_focus_exited(index: int):
	# Esconde o seletor correto
	match index:
		0: seletor1.visible = false
		1: seletor2.visible = false
		2: seletor3.visible = false
# [Em: tela_recompensa.gd]
# (SUBSTITUA ESTA FUNÇÃO INTEIRA)

func _on_nicho_pressed(index: int):
	var id_escolhido = upgrades_oferecidos[index]
	var save_data = SaveManager.dados_atuais
	var data = UpgradeDatabase.get_upgrade_data(id_escolhido)
	
	if save_data == null or data.is_empty():
		push_error("Falha ao aplicar upgrade. SaveData ou UpgradeData não encontrados.")
		_avancar_e_fechar()
		return

	match id_escolhido:
		"upgrade_vida_maxima":
			save_data.bonus_vida_maxima += 15.0
		"upgrade_energia_maxima":
			save_data.bonus_energia_maxima += 20.0
		"upgrade_velocidade_movimento":
			save_data.bonus_velocidade_movimento += 5.0 
		
		"upgrade_cargas_cura":
			save_data.bonus_cargas_cura += 1
		"upgrade_potencia_cura":
			save_data.bonus_potencia_cura += 10.0 
		"upgrade_cura_por_morte":
			save_data.bonus_cura_por_morte += 1.0 
		
		# --- CORREÇÃO (Bug #8) ---
		"upgrade_reducao_dano":
			save_data.bonus_reducao_dano += 2.0 # (Cada upgrade dá 2 pontos de redução)
		# --- FIM DA CORREÇÃO ---
			
		# --- CORREÇÃO (Bug #3) ---
		"upgrade_dano_espada":
			save_data.bonus_dano_espada += 3.0 # (Baixamos de 5.0 para 3.0)
		# --- FIM DA CORREÇÃO ---
			
		"upgrade_dano_espada_especial":
			save_data.bonus_dano_espada_especial += 10.0
			
		"upgrade_cadencia_arco":
			save_data.bonus_cadencia_arco += 0.05 
		"upgrade_rajada_flechas":
			save_data.bonus_rajada_flechas += 1
			
		"upgrade_cadencia_magia":
			save_data.bonus_cadencia_magia += 0.1 
		"upgrade_leque_misseis":
			save_data.bonus_leque_misseis += 1
			
		"upgrade_conservar_energia":
			save_data.conserva_energia_entre_ondas = true
		
		"upgrade_eficiencia_energia":
			save_data.bonus_eficiencia_energia += 5.0 
		
		_:
			push_warning("Upgrade '%s' (Titulo: %s) foi escolhido, mas não há lógica de aplicação!" % [id_escolhido, data.titulo])

	Logger.log("Upgrade adquirido: %s" % data.titulo)
	_avancar_e_fechar()
func _avancar_e_fechar():
	get_tree().paused = false
	GameManager.avancar_para_proxima_onda() # Diz ao GM para recarregar a cena
	queue_free()
