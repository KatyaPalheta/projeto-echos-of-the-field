# [Script: UpgradeDatabase.gd]
# (VERSÃO FINAL - Sincronizado com sua planilha 'image_abcabd.png')
extends Node

# O "tipo" define como o upgrade é tratado:
# - "stack": Pode aparecer várias vezes (ex: +10% Dano)
# - "unico": Só pode ser pego uma vez (ex: "Bateria Arcana")
# - "habilidade": Desbloqueia uma nova ação (ex: "Rajada Extra")

const DB = {
	# --- Stats Base ---
	"upgrade_vida_maxima": {
		"titulo": "Vigor",
		"descricao": "Aumenta sua Vida Máxima total.",
		"icone_path": "res://assets/skills/upgrade_vida_maxima.png",
		"tipo": "stack"
	},
	"upgrade_energia_maxima": {
		"titulo": "Alma Expandida",
		"descricao": "Aumenta sua Energia Máxima total (para especiais).",
		"icone_path": "res://assets/skills/upgrade_energia_maxima.png",
		"tipo": "stack"
	},
	"upgrade_velocidade_movimento": {
		"titulo": "Botas Leves",
		"descricao": "Aumenta sua velocidade de movimento.",
		"icone_path": "res://assets/skills/upgrade_velocidade_movimento.png",
		"tipo": "stack"
	},
	"upgrade_resistencia_knockback": {
		"titulo": "Pés de Chumbo",
		"descricao": "Reduz o quanto você é empurrado por ataques inimigos.",
		"icone_path": "res://assets/skills/upgrade_resistencia_knockback.png",
		"tipo": "stack"
	},

	# --- Defesa / Recuperação ---
	"upgrade_cargas_cura": {
		"titulo": "Estrela Extra",
		"descricao": "Adiciona +1 Carga de Cura (Máx: 3). (Efeito Único)",
		"icone_path": "res://assets/skills/upgrade_cargas_cura.png",
		"tipo": "unico" 
	},
	"upgrade_potencia_cura": {
		"titulo": "Bênção Potente",
		"descricao": "Aumenta a quantidade de Vida que cada Carga de Cura recupera.",
		"icone_path": "res://assets/skills/upgrade_potencia_cura.png",
		"tipo": "stack"
	},
	"upgrade_reducao_dano": {
		"titulo": "Escudo Rúnico",
		"descricao": "Reduz uma pequena quantidade de dano de todos os ataques sofridos.",
		"icone_path": "res://assets/skills/upgrade_reducao_dano.png",
		"tipo": "stack"
	},
	"upgrade_cura_por_morte": {
		"titulo": "Vampirismo",
		"descricao": "Recupera uma pequena quantidade de Vida a cada inimigo derrotado.",
		"icone_path": "res://assets/skills/upgrade_cura_por_morte.png",
		"tipo": "stack" 
	},

	# --- Espada ---
	"upgrade_dano_espada": {
		"titulo": "Lâmina Afiada",
		"descricao": "Aumenta o dano do seu ataque básico com a espada.",
		"icone_path": "res://assets/skills/upgrade_dano_espada.png",
		"tipo": "stack"
	},
	"upgrade_dano_espada_especial": {
		"titulo": "Fúria Dupla",
		"descricao": "Aumenta o dano do seu Golpe Duplo com a espada.",
		"icone_path": "res://assets/skills/upgrade_dano_espada_especial.png",
		"tipo": "stack"
	},

	# --- Arco ---
	"upgrade_cadencia_arco": {
		"titulo": "Corda Rápida",
		"descricao": "Reduz o tempo de recarga entre os disparos do arco.",
		"icone_path": "res://assets/skills/upgrade_cadencia_arco.png",
		"tipo": "stack"
	},
	"upgrade_velocidade_flecha": {
		"titulo": "Flechas Aerodinâmicas",
		"descricao": "Aumenta a velocidade das suas flechas.",
		"icone_path": "res://assets/skills/upgrade_velocidade_flecha.png",
		"tipo": "stack"
	},
	"upgrade_rajada_flechas": {
		"titulo": "Rajada Extra",
		"descricao": "Adiciona +1 flecha à sua Rajada de Flechas.",
		"icone_path": "res://assets/skills/upgrade_rajada_flechas.png",
		"tipo": "habilidade" # (Era "Tiro Triplo", mas "Rajada Extra" é melhor)
	},
	"upgrade_velocidade_rajada": {
		"titulo": "Rajada Veloz",
		"descricao": "Dispara as flechas da Rajada mais rapidamente.",
		"icone_path": "res://assets/skills/upgrade_velocidade_rajada.png",
		"tipo": "stack"
	},

	# --- Magia ---
	"upgrade_cadencia_magia": {
		"titulo": "Canalização Rápida",
		"descricao": "Reduz o tempo de recarga entre os Mísseis de Fogo.",
		"icone_path": "res://assets/skills/upgrade_cadencia_magia.png",
		"tipo": "stack"
	},
	"upgrade_velocidade_missil": {
		"titulo": "Propulsão Arcana",
		"descricao": "Aumenta a velocidade dos seus Mísseis de Fogo.",
		"icone_path": "res://assets/skills/upgrade_velocidade_missil.png",
		"tipo": "stack"
	},
	"upgrade_leque_misseis": {
		"titulo": "Leque Incendiário",
		"descricao": "Adiciona +1 Míssil de Fogo ao seu Leque de Mísseis.",
		"icone_path": "res://assets/skills/upgrade_leque_misseis.png",
		"tipo": "habilidade" # (Era "Tridente", mas "Leque Incendiário" é melhor)
	},
	"upgrade_foco_leque": {
		"titulo": "Fogo Concentrado",
		"descricao": "Reduz a abertura do Leque de Mísseis (concentra o dano).",
		"icone_path": "res://assets/skills/upgrade_foco_leque.png",
		"tipo": "stack"
	},

	# --- Táticos / Críticos ---
	"upgrade_eficiencia_energia": {
		"titulo": "Foco de Batalha",
		"descricao": "Reduz o custo de Energia de todos os ataques especiais.",
		"icone_path": "res://assets/skills/upgrade_eficiencia_energia.png",
		"tipo": "stack"
	},
	"upgrade_conservar_energia": {
		"titulo": "Bateria Arcana",
		"descricao": "Você mantém a Energia acumulada entre as ondas. (Efeito Único)",
		"icone_path": "res://assets/skills/upgrade_conservar_energia.png",
		"tipo": "unico" 
	},
	"upgrade_chance_critico": {
		"titulo": "Olho Aguçado",
		"descricao": "Aumenta sua chance de causar um Acerto Crítico.",
		"icone_path": "res://assets/skills/upgrade_chance_critico.png",
		"tipo": "stack"
	},
	"upgrade_dano_critico": {
		"titulo": "Golpe Devastador",
		"descricao": "Aumenta o multiplicador de dano dos seus Acertos Críticos.",
		"icone_path": "res://assets/skills/upgrade_dano_critico.png",
		"tipo": "stack"
	},
}


# API "Pública" do nosso banco de dados

# Retorna os dados de um upgrade específico
func get_upgrade_data(id: String) -> Dictionary:
	if DB.has(id):
		return DB[id]
	push_warning("UpgradeDatabase: ID de upgrade não encontrado no DB: %s" % id)
	return {}


# A função CHAVE: Pega N upgrades aleatórios que o jogador AINDA NÃO POSSUI
func get_random_upgrades(amount: int) -> Array[String]:
	
	if SaveManager.dados_atuais == null:
		push_error("UpgradeDatabase não conseguiu acessar o SaveManager.dados_atuais!")
		return []

	var dados_save = SaveManager.dados_atuais
	
	# 1. Pega TODOS os IDs (chaves) do nosso banco de dados
	var pool_de_upgrades: Array[String] = DB.keys()
	
	# 2. FILTRAGEM: Remove os upgrades do tipo "unico" ou "habilidade"
	#    que o jogador já possui no SaveGame.
	
	# (Vamos iterar de trás para frente para poder remover itens com segurança)
	for i in range(pool_de_upgrades.size() - 1, -1, -1):
		var id_upgrade = pool_de_upgrades[i]
		var dados_upgrade = DB[id_upgrade]
		
		# Se não for "stackable", checamos se já o temos
		if dados_upgrade.tipo == "unico" or dados_upgrade.tipo == "habilidade":
			
			# Checagens específicas baseadas no SaveGame.gd
			match id_upgrade:
				"upgrade_conservar_energia":
					if dados_save.conserva_energia_entre_ondas:
						pool_de_upgrades.remove_at(i)
				
				"upgrade_cargas_cura":
					# (Lógica bônus: só oferece se o jogador tiver menos de 3)
					var cargas_atuais_base = 3 # (O player começa com 3) [cite: 3]
					var bonus_cargas = dados_save.bonus_cargas_cura
					if (cargas_atuais_base + bonus_cargas) >= 3:
						pool_de_upgrades.remove_at(i)

				"upgrade_rajada_flechas":
					if dados_save.tem_upgrade_rajada_flechas:
						pool_de_upgrades.remove_at(i)
						
				"upgrade_leque_misseis":
					if dados_save.tem_upgrade_leque_misseis:
						pool_de_upgrades.remove_at(i)
	
	# 3. Embaralha o pool que sobrou
	pool_de_upgrades.shuffle()
	
	# 4. Retorna a quantidade pedida (ou menos, se o pool acabar)
	var final_amount = min(amount, pool_de_upgrades.size())
	return pool_de_upgrades.slice(0, final_amount)
