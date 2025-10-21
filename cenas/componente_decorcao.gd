extends Node2D
class_name ComponenteDecoracao

## --- Listas de Textura ---
@export_category("Listas de Texturas")
@export var lista_texturas_flores: Array[String]
@export var lista_texturas_grama: Array[String]
@export var lista_texturas_arvores: Array[String]

## --- Configuração dos Perfis de Spawn ---
@export_category("Configuracao de Spawn")
# Use valores entre 0.0 e 1.0. A soma deles deve ser 1.0
@export_range(0.0, 1.0) var chance_so_grama: float = 0.5  # 50%
@export_range(0.0, 1.0) var chance_so_flores: float = 0.2 # 20%
# O resto (30%) será Arvores + Flores

@export var area_de_espalhamento: Rect2 = Rect2(-8, -8, 32, 32)
@export var max_tentativas_pos: int = 20

## --- Configurações das Flores ---
@export_category("Flores")
@export var min_flores: int = 2
@export var max_flores: int = 5
@export var distancia_min_flores: float = 10.0
@export var offset_flor: Vector2 = Vector2(8, 16) # Offset para Y-Sort (base da flor)

## --- Configurações da Grama ---
@export_category("Grama")
@export var min_grama: int = 4
@export var max_grama: int = 8
@export var distancia_min_grama: float = 4.0
@export var offset_grama: Vector2 = Vector2(8, 16) # Offset para Y-Sort (base da grama)

## --- Configurações das Árvores ---
@export_category("Arvores")
@export var min_arvores: int = 1
@export var max_arvores: int = 1
@export var distancia_min_arvores: float = 16.0 # Pelo menos metade da largura
# MUITO IMPORTANTE: O offset da árvore para o Y-Sort (base no centro)
@export var offset_arvore: Vector2 = Vector2(16, 48) # Metade de 32, altura total de 48


# Variáveis de controle
var posicoes_usadas: Array[Dictionary] = []
var ja_gerou: bool = false # Trava para gerar só 1 vez
var vegetacao_container: Node2D

func _ready() -> void:
	# Cria o container que vai segurar a vegetação
	vegetacao_container = Node2D.new()
	vegetacao_container.name = "VegetacaoContainer"
	add_child(vegetacao_container)

# A lógica de "nascer" agora acontece quando entra na tela PELA PRIMEIRA VEZ
func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	vegetacao_container.visible = true # Mostra o componente
	
	# Se já gerou a decoração, não faz mais nada
	if ja_gerou:
		return
		
	# Trava para não gerar de novo
	ja_gerou = true
	
	# 1. Rolar o dado para decidir o "perfil"
	var roleta: float = randf() # Sorteia um número de 0.0 a 1.0
	
	if roleta < chance_so_grama:
		# --- Perfil: Somente Grama ---
		if lista_texturas_grama.is_empty(): return
		_gerar_coisas(
			lista_texturas_grama,
			randi_range(min_grama, max_grama),
			distancia_min_grama,
			offset_grama,
			"Grama"
		)
		
	elif roleta < chance_so_grama + chance_so_flores:
		# --- Perfil: Somente Flores ---
		if lista_texturas_flores.is_empty(): return
		_gerar_coisas(
			lista_texturas_flores,
			randi_range(min_flores, max_flores),
			distancia_min_flores,
			offset_flor,
			"Flor"
		)
		
	else:
		# --- Perfil: Árvores e Flores ---
		if lista_texturas_arvores.is_empty() and lista_texturas_flores.is_empty(): return
		
		# 1. Gera as Árvores primeiro (porque são maiores e mais importantes)
		_gerar_coisas(
			lista_texturas_arvores,
			randi_range(min_arvores, max_arvores),
			distancia_min_arvores,
			offset_arvore,
			"Arvore"
		)
		
		# 2. Gera as Flores em volta
		_gerar_coisas(
			lista_texturas_flores,
			randi_range(min_flores, max_flores),
			distancia_min_flores,
			offset_flor,
			"Flor"
		)

# A função de sair da tela continua igual
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	vegetacao_container.visible = false


# --- FUNÇÕES "HELPER" ---

# Função genérica que cria e posiciona os sprites
# Substitua a sua função _gerar_coisas inteira por esta:
func _gerar_coisas(lista_texturas: Array, quantidade: int, dist_min: float, sprite_offset: Vector2, nome: String) -> void:
	for i in range(quantidade):
		# Tenta achar uma posição válida
		var nova_posicao: Variant = _encontrar_posicao_valida(dist_min)
		
		# Se não achou (retornou null), desiste de gerar ESTE sprite
		if nova_posicao == null:
			continue
			
		# Se achou, cria o Sprite
		var novo_sprite = Sprite2D.new()
		novo_sprite.texture = load(lista_texturas.pick_random())
		
		# === A CORREÇÃO MÁGICA DO Y-SORT ===
		# 1. Diz que a 'position' é no canto (0,0) do sprite, não no centro
		novo_sprite.centered = false 
		# 2. Define a 'position' (os "pés") para a posição sorteada
		novo_sprite.position = nova_posicao
		# 3. Usa o offset NEGATIVO para "puxar" a textura para cima e para a esquerda
		novo_sprite.offset = -sprite_offset 
		# ===================================
		
		novo_sprite.name = "%s_%s" % [nome, i] # Dá um nome (bom pra debugar)
		
		# Adiciona o sprite como filho do Container
		vegetacao_container.add_child(novo_sprite)


# A nossa lógica de achar um lugar, agora em uma função separada
# Substitua a sua função _encontrar_posicao_valida inteira por esta:
func _encontrar_posicao_valida(distancia_minima_nova: float) -> Variant:
	var nova_posicao: Vector2
	var posicao_encontrada: bool = false
	
	# Tenta N vezes achar um lugar
	for _i in max_tentativas_pos:
		# Gera uma posição aleatória dentro da área
		nova_posicao = Vector2(
			randf_range(area_de_espalhamento.position.x, area_de_espalhamento.end.x),
			randf_range(area_de_espalhamento.position.y, area_de_espalhamento.end.y)
		)
		
		# Checa se está longe das posições já usadas
		var muito_perto: bool = false
		for item_existente in posicoes_usadas:
			var pos_existente: Vector2 = item_existente["pos"]
			var dist_existente: float = item_existente["dist"] # Pega a distância do item antigo
			var distancia_atual: float = nova_posicao.distance_to(pos_existente)
			
			# Checa a distância dos DOIS:
			if distancia_atual < distancia_minima_nova or distancia_atual < dist_existente:
				muito_perto = true
				break
		
		if not muito_perto:
			posicao_encontrada = true
			break
	
	if posicao_encontrada:
		# Guarda um dicionário (posição E distância)
		posicoes_usadas.append({"pos": nova_posicao, "dist": distancia_minima_nova})
		return nova_posicao
	else:
		return null
