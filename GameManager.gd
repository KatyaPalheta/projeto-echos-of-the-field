extends Node

# O sinal que o HUD vai ouvir
signal stats_atualizadas(inimigos_mortos, inimigos_total, onda_atual)

# --- REGRAS DA "BI" (Nós!) ---
# Formato: [Inimigos para Matar, Chance de Spawn]
var ONDAS = [
	[10, 0.005], # Onda 1: Matar 10, chance de 5%
	[15, 0.008], # Onda 2: Matar 20, chance de 8%
	[20, 0.01]  # Onda 3: Matar 40, chance de 12%
]

# --- DADOS PERSISTENTES (O que o jogo "lembra") ---
var onda_atual_index: int = 0
var inimigos_mortos: int = 0
var inimigos_total_na_onda: int = 10
var player_ref: Node2D = null

# (Futuro) Aqui é onde as "cartinhas" vão ficar:
# var bonus_velocidade: float = 0.0
# var bonus_cargas_cura: int = 0

func set_player_reference(player: Node2D):
	player_ref = player
# Chamado pelo GerenciadorDeTerreno quando o jogo começa
func iniciar_onda() -> float:
	inimigos_mortos = 0
	var dados_onda = ONDAS[onda_atual_index]

	inimigos_total_na_onda = dados_onda[0]
	var chance_spawn = dados_onda[1]

	# Avisa o HUD para atualizar (ex: "0 / 10")
	emit_signal.call_deferred("stats_atualizadas", inimigos_mortos, inimigos_total_na_onda, onda_atual_index + 1)

	# Retorna a "densidade" (chance) para o GerenciadorDeTerreno
	return chance_spawn

func registrar_morte_inimigo():
	inimigos_mortos += 1

	# 1. Avisa o HUD para atualizar (ex: "1 / 10")
	emit_signal("stats_atualizadas", inimigos_mortos, inimigos_total_na_onda, onda_atual_index + 1)

	Logger.log("Inimigo derrotado! (%s / %s)" % [inimigos_mortos, inimigos_total_na_onda])

	# 2. Agora o Cérebro Mestre também dá a energia! (A LÓGICA QUE FALTAVA)
	if player_ref != null:
		player_ref.ganhar_energia(25.0) # (Usamos 25.0, o valor antigo)
	
	# 3. A LÓGICA DE VITÓRIA DA ONDA (O BLOCO QUE FALTAVA)
	if inimigos_mortos >= inimigos_total_na_onda:
		Logger.log("Onda %s completa!" % (onda_atual_index + 1))

		# Avança para a próxima onda
		onda_atual_index += 1

		# Checa se o jogo acabou
		if onda_atual_index >= ONDAS.size():
			Logger.log("VOCÊ VENCEU A DEMO!")
			onda_atual_index = 0 # Recomeça do zero

		# "dar refresh no game level"
		get_tree().call_deferred("change_scene_to_file", get_tree().current_scene.scene_file_path)
