extends Node2D

# --- As Ferramentas (Nós que vamos controlar) ---
@onready var water_layer: TileMapLayer = $water_atlas
@onready var land_layer: TileMapLayer = $land_atlas
@onready var sand_layer: TileMapLayer = $sand_atlas

# --- Cena de Decoração ---
@export var cena_decoracao: PackedScene
@export var player_node: Node2D
@export var cena_slime: PackedScene
@export_range(0.0, 1.0) var chance_inimigo: float = 0.05 # <-- 5% de chance por tile

# --- Lista de Máscaras ---
@export var lista_mascaras: Array[String] = [
	"res://assets/terrain/templateterreno1.png", # <-- CONFIRA OS CAMINHOS!
	"res://assets/terrain/templateterren2.png",
	"res://assets/terrain/templateterren3.png",
	"res://assets/terrain/templateterren4.png"
]
@export var mascara_para_usar_index: int = -1 # -1 = Aleatório

# --- Cores da Máscara ---
# (Certifique-se de que a cor da água também está correta!)
@export var cor_agua: Color = Color("#0000FF") # <-- CONFIRME O HEX DO SEU AZUL
@export var cor_grama: Color = Color("#7CFF00") # <-- TROQUE PELO HEX DO SEU VERDE
@export var cor_areia: Color = Color("#F4A460") # <-- TROQUE PELO HEX DA SUA AREIA
@export var cor_spawn: Color = Color("#FF0000") # <-- TROQUE PELO HEX DO SEU VERMELHO

# --- Configuração do TileSet ---
@export var id_fonte_tileset: int = 0
@export var tile_agua: Vector2i = Vector2i(22, 5)

# --- IDs DOS TERRENOS (Simplificado) ---
const TERRAIN_SET_PADRAO: int = 0
const TERRAIN_PADRAO: int = 0

# --- Configuração do Mundo ---
# (O tamanho será ajustado pela máscara no _ready)
@export var tamanho_mundo: Vector2i = Vector2i(100, 100)
@export_range(0.0, 1.0) var chance_decoracao: float = 0.25

# --- Variáveis de Controle (Spawn) ---
var spawn_point_encontrado: bool = false
var spawn_position: Vector2 = Vector2.ZERO


func _ready() -> void:

	Logger.log("Fase 1: Iniciando Geração (Com Spawn Seguro!)...")

	# --- PASSO 0: ESCOLHER E CARREGAR A MÁSCARA ---
	if lista_mascaras.is_empty():
		push_error("ERRO: A lista de máscaras está vazia!")
		return

	var caminho_mascara: String
	if mascara_para_usar_index >= 0 and mascara_para_usar_index < lista_mascaras.size():
		caminho_mascara = lista_mascaras[mascara_para_usar_index]
		Logger.log("Usando máscara específica: %s" % caminho_mascara)
	else:
		caminho_mascara = lista_mascaras.pick_random() # Sorteia!
		Logger.log("Sorteando máscara: %s" % caminho_mascara)

	var mask_texture: Texture2D = load(caminho_mascara)
	if mask_texture == null:
		push_error("ERRO: Não foi possível carregar a textura da máscara: " + caminho_mascara)
		return

	var mask_image: Image = mask_texture.get_image()
	if mask_image == null or mask_image.is_empty():
		push_error("ERRO: Não foi possível obter os dados da imagem da máscara: " + caminho_mascara)
		return

	tamanho_mundo = Vector2i(mask_image.get_width(), mask_image.get_height())
	Logger.log("Tamanho do mundo ajustado para o da máscara: %s" % tamanho_mundo)
	# --- FIM PASSO 0 ---

	# --- PASSO 1: PLANEJAMENTO (LENDO AS CORES E ACHANDO O SPAWN!) ---
	var coords_agua: Array[Vector2i] = []
	var coords_grama: Array[Vector2i] = []
	var coords_areia: Array[Vector2i] = []

	# Resetamos as variáveis de spawn a cada geração
	spawn_point_encontrado = false
	spawn_position = Vector2.ZERO

	# ... (código de carregar a máscara) ...

	for x in range(tamanho_mundo.x):
		for y in range(tamanho_mundo.y):
			var coords = Vector2i(x, y)
			var pixel_color: Color = mask_image.get_pixel(x, y)

			# --- LÓGICA ATUALIZADA ---
			
			# 1. Checa o SPAWN PRIMEIRO (o ponto vermelho)
			if pixel_color.is_equal_approx(cor_spawn):
				# É o spawn! Pinta AREIA (como você sugeriu) e salva a posição
				coords_areia.append(coords)
				
				# Se já não achamos um spawn, este é o principal!
				if not spawn_point_encontrado:
					spawn_position = land_layer.map_to_local(coords)
					spawn_point_encontrado = true
					print("Ponto de SPAWN DESIGNADO encontrado em: ", coords)
			
			# 2. Se não for spawn, checa o resto
			elif pixel_color.is_equal_approx(cor_agua):
				coords_agua.append(coords)
			elif pixel_color.is_equal_approx(cor_areia):
				coords_areia.append(coords)
			elif pixel_color.is_equal_approx(cor_grama):
						
				# --- AS LINHAS QUE FALTAVAM! ---
				coords_grama.append(coords)
				if randf() < chance_decoracao:
					_plantar_decoracao(coords)
				
				if cena_slime != null and randf() < chance_inimigo:
					_plantar_inimigo(coords)
				# --- FIM DA ADIÇÃO ---
			
			# (A lógica antiga do "primeiro ponto seguro" foi REMOVIDA!)

	Logger.log("Planejamento Concluído. Desenhando o mapa...")

	# --- PASSO 2: DESENHAR TUDO DE UMA VEZ (INVERTIDO!) ---
	
	# 1. Pinta a GRAMA (com "CARIMBO" normal, usando o tile central)
	# (Precisamos achar a coordenada do tile 100% verde de novo!)
	var tile_grama_centro_real = Vector2i(21, 6) # <-- CONFIRME ESSA COORDENADA!
	for coords in coords_grama:
		land_layer.set_cell(coords, id_fonte_tileset, tile_grama_centro_real)

	# 2. Pinta a ÁGUA (com o "PINCEL MÁGICO" dela!)
	water_layer.set_cells_terrain_connect(coords_agua, TERRAIN_SET_PADRAO, TERRAIN_PADRAO)

	# 3. Pinta a AREIA (com o "PINCEL MÁGICO" dela!)
	sand_layer.set_cells_terrain_connect(coords_areia, TERRAIN_SET_PADRAO, TERRAIN_PADRAO)


	# --- PASSO 3: LIMPAR OVERLAPS (AJUSTADO!) ---
	# (Agora a gente apaga a água onde tem grama/areia)
	Logger.log("Limpando overlaps...")
	for coords in coords_agua:
		# Não precisamos mais apagar land/sand aqui, eles desenham por cima
		pass 
	for coords in coords_areia:
		land_layer.erase_cell(coords) # Areia apaga Grama
		water_layer.erase_cell(coords) # Areia apaga Água
	for coords in coords_grama:
		sand_layer.erase_cell(coords) # Grama apaga Areia
		water_layer.erase_cell(coords) # Grama apaga Água

	# --- FASE FINAL: POSICIONAR O PLAYER (NO PONTO SEGURO!) ---
	if player_node != null:
		if spawn_point_encontrado:
			# Usa a posição que salvamos e adiciona offset para centralizar
			player_node.global_position = spawn_position + Vector2(8, 8)
			if player_node.has_method("set_tilemap_refs"):
				player_node.set_tilemap_refs(land_layer, sand_layer)
			# --- FIM DA ADIÇÃO ---
			Logger.log("Player posicionado no PRIMEIRO PONTO SEGURO em: %s" % player_node.global_position)
		else:
			push_warning("Nenhum ponto de spawn seguro foi encontrado!Verifique suas máscaras.")
			player_node.global_position = Vector2.ZERO # Coloca no (0,0) como fallback
	else:
		push_warning("Nó do Player não foi configurado no GerenciadorDeTerreno!")
	if player_node != null:
		player_node.player_morreu.connect(_on_player_morreu)
	else:
		push_warning("GerenciadorDeTerreno: player_node não configurado! Inimigos não fugirão.")	
# --- NOVA FUNÇÃO HELPER ---

func _plantar_inimigo(coords_do_tile: Vector2i) -> void:
	# 1. Cria (instancia) a cena do slime
	var new_slime = cena_slime.instantiate()

	# 2. Calcula a posição global (no mundo) do canto do tile
	var pos_global_tile = land_layer.map_to_local(coords_do_tile)

	# 3. Define a posição do novo slime (centralizado no tile)
	new_slime.global_position = pos_global_tile + Vector2(8, 8) 

	# 4. Adiciona o novo slime à cena
	add_child(new_slime)

# --- Função "Helper" _plantar_decoracao (VAI AQUI!) ---
func _plantar_decoracao(coords_do_tile: Vector2i) -> void:
	# Checa se a cena de decoração foi configurada no Inspetor
	if cena_decoracao == null:
		push_warning("Cena de decoração não configurada no Gerenciador!")
		return # Sai da função se não tiver cena

	# Instancia (cria) uma nova cópia da cena de decoração
	var nova_decoracao = cena_decoracao.instantiate()

	# Calcula a posição global (no mundo) do canto do tile
	var pos_global_tile = land_layer.map_to_local(coords_do_tile)

	# Define a posição da nova decoração para ser EXATAMENTE no canto do tile
	nova_decoracao.position = pos_global_tile

	# Adiciona a nova decoração como filha do GerenciadorDeTerreno
	add_child(nova_decoracao)
# Esta função é chamada pelo SINAL do Player
func _on_player_morreu() -> void:
	Logger.log("GERENCIADOR: Player morreu! Agora os inimigos fogem!")

	# Pega a posição do player para os inimigos saberem de onde fugir
	var player_pos = player_node.global_position

	# "Grita" para todos no grupo "inimigos"
	# para eles rodarem a função "fugir_do_player"
	get_tree().call_group("inimigos", "fugir_do_player", player_pos)
# <<< FIM DO SCRIPT >>>
