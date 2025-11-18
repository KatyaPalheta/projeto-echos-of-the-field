# [Script: SaveManager.gd]
# (Versão com o novo sinal e função de registro)
extends Node

signal upgrades_da_partida_mudaram # <-- SINAL ADICIONADO

# O caminho onde vamos salvar o jogo
const SAVE_PATH = "user://savegame.tres"

# A "instância viva" dos nossos dados
var dados_atuais: SaveGame

# --- FUNÇÕES INTERNAS DO GODOT ---

func _ready():
	carregar_dados()
	Logger.log("SaveManager pronto. Tempo total já gasto: %s" % get_tempo_total_formatado())

func _process(_delta: float):
	# O cronômetro global
	if dados_atuais != null:
		dados_atuais.tempo_total_gasto += _delta

# --- NOSSAS FUNÇÕES PÚBLICAS ---

func carregar_dados():
	if ResourceLoader.exists(SAVE_PATH):
		dados_atuais = ResourceLoader.load(SAVE_PATH)
		Logger.log("Save carregado do disco!")
	else:
		Logger.log("Nenhum save encontrado. Criando um novo.")
		dados_atuais = SaveGame.new()
		dados_atuais.tempo_total_gasto = 0.0
		dados_atuais.onda_mais_alta_salva = 1
		dados_atuais.personagem_escolhido = "Heroina"
		salvar_dados()

func salvar_dados():
	if dados_atuais == null:
		Logger.log("[ERRO] Tentativa de salvar dados nulos!")
		return
		
	var erro = ResourceSaver.save(dados_atuais, SAVE_PATH)
	if erro == OK:
		Logger.log("Jogo salvo com sucesso em: %s" % SAVE_PATH)
	else:
		Logger.log("[ERRO] FALHA AO SALVAR O JOGO! Código: %s" % erro)

func get_tempo_total_formatado() -> String:
	if dados_atuais == null:
		return "00:00"
		
	# 1. Pega o tempo como float (decimal)
	var tempo_float: float = dados_atuais.tempo_total_gasto
	
	# 2. Arredonda para baixo a divisão de floats
	var minutos = int(floor(tempo_float / 60.0))
	
	# 3. Pega o "resto" dos segundos (usando a função de resto de float)
	var segundos = int(fmod(tempo_float, 60.0))
	
	return "%02d:%02d" % [minutos, segundos]

# --- FUNÇÃO ADICIONADA ---
# A futura "Tela de Upgrade" vai chamar esta função
func registrar_upgrade_escolhido(id_upgrade: String):
	if dados_atuais == null:
		Logger.log("[ERRO] SaveManager não pôde registrar upgrade, dados nulos!")
		return
		
	# 1. Atualiza o dicionário (exatamente como planejamos)
	if not dados_atuais.upgrades_da_partida.has(id_upgrade):
		dados_atuais.upgrades_da_partida[id_upgrade] = 1
	else:
		dados_atuais.upgrades_da_partida[id_upgrade] += 1
	
	Logger.log("Upgrade registrado: %s (Total: %s)" % [id_upgrade, dados_atuais.upgrades_da_partida[id_upgrade]])
	
	# 2. Emite o "sinal mestre" para a HUD (ou quem quiser) ouvir
	emit_signal("upgrades_da_partida_mudaram")
	
	# 3. (Importante): Salva os dados no disco
	# Assim, se o jogador fechar o jogo, o dicionário está salvo.
	salvar_dados()
