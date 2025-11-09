# [Script: SaveManager.gd]
extends Node

# O caminho onde vamos salvar o jogo
# "user://" aponta para a pasta segura de dados do jogador (local ou no navegador)
const SAVE_PATH = "user://savegame.tres"

# A "instância viva" dos nossos dados. 
# Usamos o 'class_name SaveGame' que criamos no Passo 1!
var dados_atuais: SaveGame

# --- FUNÇÕES INTERNAS DO GODOT ---

func _ready():
	# Quando o jogo abre pela primeira vez, tenta carregar o save
	carregar_dados()
	Logger.log("SaveManager pronto. Tempo total já gasto: %s" % get_tempo_total_formatado())

func _process(delta: float):
	# --- O SEU CRONÔMETRO GLOBAL! ---
	# A cada frame, ele incrementa os segundos na nossa "instância viva"
	if dados_atuais != null:
		dados_atuais.tempo_total_gasto += delta

# --- NOSSAS FUNÇÕES PÚBLICAS (para outros scripts) ---

func carregar_dados():
	if ResourceLoader.exists(SAVE_PATH):
		# 1. Se o arquivo "savegame.tres" existe, carrega ele
		dados_atuais = ResourceLoader.load(SAVE_PATH)
		Logger.log("Save carregado do disco!")
	else:
		# 2. Se não existe, cria um novo "SaveGame" zerado
		Logger.log("Nenhum save encontrado. Criando um novo.")
		dados_atuais = SaveGame.new()
		dados_atuais.tempo_total_gasto = 0.0
		dados_atuais.onda_mais_alta_salva = 1
		dados_atuais.personagem_escolhido = "Heroina"
		
		# (E salva ele pela primeira vez)
		salvar_dados()

func salvar_dados():
	if dados_atuais == null:
		Logger.log("Erro: Tentativa de salvar dados nulos!", "ERROR")
		return
		
	# Salva o nosso recurso (que está na memória) no disco
	var erro = ResourceSaver.save(dados_atuais, SAVE_PATH)
	if erro == OK:
		Logger.log("Jogo salvo com sucesso em: %s" % SAVE_PATH)
	else:
		Logger.log("FALHA AO SALVAR O JOGO! Erro: %s" % erro, "ERROR")

# (Uma função "helper" para o HUD pegar o tempo formatado)
func get_tempo_total_formatado() -> String:
	if dados_atuais == null:
		return "00:00"
		
	var total_segundos = int(dados_atuais.tempo_total_gasto)
	var minutos = total_segundos / 60
	var segundos = total_segundos % 60
	
	# Formata para "01:30"
	return "%02d:%02d" % [minutos, segundos]
