extends Node2D

# --- As Ferramentas (Nós que vamos controlar) ---
@onready var water_layer: TileMapLayer = $water_atlas
@onready var land_layer: TileMapLayer = $land_atlas
@onready var sand_layer: TileMapLayer = $sand_atlas

# --- Cena de Decoração ---
@export var cena_decoracao: PackedScene
@export var player_node: Node2D

# --- Configuração do TileSet (A CORREÇÃO FINAL!) ---
@export var id_fonte_tileset: int = 0
@export var tile_agua: Vector2i = Vector2i(22, 5) # O "carimbo" da água

# --- IDs dos Terrenos (AS VARIÁVEIS QUE FALTAVAM!) ---
# O ID do *Conjunto* de Terreno da Grama (provavelmente 0)
@export var id_terrain_set_GRAMA: int = 0
# O ID do *Elemento* de Grama dentro desse conjunto (provavelmente 0)
@export var id_terrain_GRAMA: int = 0

# O ID do *Conjunto* de Terreno da Areia (provavelmente 1)
@export var id_terrain_set_AREIA: int = 1
# O ID do *Elemento* de Areia dentro desse conjunto (provavelmente 0)
@export var id_terrain_AREIA: int = 0
# ---------------------------------------------------

# --- Configuração do Mundo ---
@export var tamanho_mundo: Vector2i = Vector2i(100, 100)
@export_range(0.0, 1.0) var chance_decoracao: float = 0.25

# --- Variáveis de Controle ---
var noise = FastNoiseLite.new()
var noise_caminhos = FastNoiseLite.new()


# --- A "Fase 1" (A "ILHONA REDONDA"!) ---
func _ready() -> void:
	
	print("Fase 1: Iniciando Geração (Versão 'ILHONA REDONDA'!)...")
	
	# Configura os "Ruídos" (igual a antes)
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = 0.03
	noise_caminhos.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise_caminhos.frequency = 0.05
	
	# --- PASSO 1: PLANEJAMENTO (COM MÁSCARA!) ---
	var coords_agua: Array[Vector2i] = []
	var coords_grama: Array[Vector2i] = []
	var coords_areia: Array[Vector2i] = []
	
	# Pega o centro do mapa (como float, para precisão)
	var centro_mapa = Vector2(tamanho_mundo) / 2.0
	
	# O Loop Principal (Planejamento)
	for x in range(tamanho_mundo.x):
		for y in range(tamanho_mundo.y):
			var coords = Vector2i(x, y)
			
			# Pega os valores de "noise" (igual a antes)
			var valor_ilha_noise = noise.get_noise_2d(x, y)
			var valor_caminho = noise_caminhos.get_noise_2d(x, y)
			
			# --- A MÁGARA RADIAL (A "ILHONA") ---
			# 1. Calcula a distância do tile atual (x,y) até o centro
			var distancia_do_centro: float = (Vector2(x, y) - centro_mapa).length()
			
			# 2. Normaliza a distância (0.0 no centro, 1.0 na borda)
			var distancia_normalizada: float = distancia_do_centro / centro_mapa.x
			
			# 3. Cria a "máscara" (um valor que é 0 no centro e 1 nas bordas)
			var valor_falloff: float = pow(distancia_normalizada, 2.5)
			
			# 4. A "MÁGICA": Subtrai a máscara do "noise" da ilha
			var valor_ilha_final: float = valor_ilha_noise - valor_falloff
			# --- FIM DA MÁSCARA ---

			# Agora, usamos 'valor_ilha_final' para decidir
			
			if valor_ilha_final > -0.4: # (Valor baixo para a ilha ser maior)
				# --- É TERRA FIRME ---
				if valor_caminho > 0.3:
					# --- É TERRA (CAMINHO) ---
					coords_areia.append(coords) # Salva na lista de Areia
				else:
					# --- NÃO É CAMINHO (só grama) ---
					coords_grama.append(coords) # Salva na lista de Grama
					if randf() < chance_decoracao:
						_plantar_decoracao(coords)
			else:
				# --- É ÁGUA ---
				coords_agua.append(coords) # Salva na lista de Água

	print("Planejamento Concluído. Desenhando o mapa...")

	# --- PASSO 2: DESENHAR TUDO DE UMA VEZ ---
	
	# 1. Pinta a ÁGUA (com "carimbo" normal)
	for coords in coords_agua:
		water_layer.set_cell(coords, id_fonte_tileset, tile_agua)

	# 2. Pinta a GRAMA (com o "Pincel" dela)
	land_layer.set_cells_terrain_connect(coords_grama, id_terrain_set_GRAMA, id_terrain_GRAMA)

	# 3. Pinta a AREIA (com o "Pincel" dela)
	sand_layer.set_cells_terrain_connect(coords_areia, id_terrain_set_AREIA, id_terrain_AREIA)

	# 4. Limpa os overlaps (usando 'erase_cell' singular)
	print("Limpando overlaps...")
	for coords in coords_agua:
		land_layer.erase_cell(coords)
		sand_layer.erase_cell(coords)
	for coords in coords_areia:
		land_layer.erase_cell(coords)
		water_layer.erase_cell(coords)
	for coords in coords_grama:
		sand_layer.erase_cell(coords)
		water_layer.erase_cell(coords)

	print("Geração Concluída! Bem-vinda à sua ILHONA!")

	# --- FASE FINAL: POSICIONAR O PLAYER (NO CENTRO!) ---
	if player_node != null:
		var spawn_coords = Vector2i(tamanho_mundo) / 2
		var spawn_pos_global = land_layer.map_to_local(spawn_coords) + Vector2(8, 8)
		player_node.global_position = spawn_pos_global
		print("Player posicionado no CENTRO DA ILHA em: ", spawn_pos_global)
	else:
		push_warning("Nó do Player não foi configurado no GerenciadorDeTerreno!")


# --- Função "Helper" (A "Fase 2" que já fizemos) ---
# (Essa parte tem que estar assim, SEM o + Vector2(8,8)!)
func _plantar_decoracao(coords_do_tile: Vector2i) -> void:
	if cena_decoracao == null:
		push_warning("Cena de decoração não configurada no Gerenciador!")
		return
		
	var nova_decoracao = cena_decoracao.instantiate()
	
	# SEM O '+ Vector2(8, 8)' para não vazar!
	nova_decoracao.position = land_layer.map_to_local(coords_do_tile)
	
	add_child(nova_decoracao)
