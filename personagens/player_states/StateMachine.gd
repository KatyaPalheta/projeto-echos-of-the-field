# [Script: StateMachine.gd]
extends Node

# O estado que está ativo agora
var current_state = null

# O estado inicial (vamos configurar no _ready)
@export var initial_state: NodePath

# Referência para o "dono" da máquina (o Player)
var player_context = null

func _ready():
	# Guarda a referência do Player (que é o nó "pai" deste StateMachine)
	player_context = get_parent()
	
	# Pega o nó do estado inicial (que definimos no Inspetor)
	var initial_state_node = get_node_or_null(initial_state)
	
	if initial_state_node == null:
		Logger.log("[ERRO] Estado inicial do Player não configurado no StateMachine!")
		return

	# Prepara todos os estados-filhos
	for state_node in get_children():
		# "Ensina" a cada estado quem é o gerente (ele mesmo) e quem é o player
		state_node.state_machine = self
		state_node.player = player_context
	
	# Inicia a máquina
	_change_state(initial_state_node)


func _input(event):
	if current_state != null:
		current_state.process_input(event)

func _physics_process(delta):
	if current_state != null:
		current_state.process_physics(delta)

# A função "mágica" que faz a troca de estados
func _change_state(new_state_node):
	# 1. Se já tínhamos um estado, chama a função 'exit' dele
	if current_state != null:
		current_state.exit()

	# 2. Atualiza para o novo estado
	current_state = new_state_node
	
	# 3. Chama a função 'enter' do novo estado
	if current_state != null:
		current_state.enter()
