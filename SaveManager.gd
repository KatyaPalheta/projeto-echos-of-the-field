# [Script: SaveManager.gd]
# (Versão corrigida dos bugs do Logger)
extends Node

# O caminho onde vamos salvar o jogo
const SAVE_PATH = "user://savegame.tres"

# A "instância viva" dos nossos dados
var dados_atuais: SaveGame

# --- FUNÇÕES INTERNAS DO GODOT ---

func _ready():
	carregar_dados()
	Logger.log("SaveManager pronto. Tempo total já gasto: %s" % get_tempo_total_formatado())

func _process(delta: float):
	# O cronômetro global
	if dados_atuais != null:
		dados_atuais.tempo_total_gasto += delta

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
		
		# --- CORREÇÃO 1 AQUI ---
		# (Colocamos o "ERRO" dentro da string)
		Logger.log("[ERRO] Tentativa de salvar dados nulos!")
		# --- FIM DA CORREÇÃO ---
		return
		
	var erro = ResourceSaver.save(dados_atuais, SAVE_PATH)
	if erro == OK:
		Logger.log("Jogo salvo com sucesso em: %s" % SAVE_PATH)
	else:
		# --- CORREÇÃO 2 AQUI ---
		# (Colocamos o "ERRO" dentro da string)
		Logger.log("[ERRO] FALHA AO SALVAR O JOGO! Código: %s" % erro)
		# --- FIM DA CORREÇÃO ---

# (Uma função "helper" para o HUD pegar o tempo formatado)
func get_tempo_total_formatado() -> String:
	if dados_atuais == null:
		return "00:00"
		
	var total_segundos = int(dados_atuais.tempo_total_gasto)
	var minutos = total_segundos / 60
	var segundos = total_segundos % 60
	
	return "%02d:%02d" % [minutos, segundos]
