# [Script: StateMachineInimigo.gd]
extends Node

# O estado que está ativo agora
var current_state = null

# O estado inicial (vamos configurar no _ready)
@export var initial_state: NodePath

# Referência para o "dono" da máquina (o InimigoBase)
var inimigo_context = null
var cerebro_context = null # (Ex: O script smile.gd)
# [Em: StateMachineInimigo.gd]
# (Substitua esta função)

func _ready():
	# --- A CORREÇÃO DE VERDADE ---
	# Força a IA a "nascer" DESLIGADA.
	# Nós não podemos confiar no Notifier se o inimigo
	# já nasce fora da tela.
	set_physics_process(false)
	# --- FIM DA CORREÇÃO ---

	# Guarda a referência do Inimigo (que é o nó "pai" deste StateMachine)
	inimigo_context = get_parent()
	cerebro_context = get_parent() # Por padrão, é o mesmo nó
	
	# Pega o nó do estado inicial (que definimos no Inspetor)
	var initial_state_node = get_node_or_null(initial_state)
	
	if initial_state_node == null:
		Logger.log("[ERRO] Estado inicial do Inimigo não configurado no StateMachine!")
		return

	# Prepara todos os estados-filhos
	for state_node in get_children(): #[cite: 77]
		# "Ensina" a cada estado quem é o gerente (ele mesmo) e quem é o inimigo
		state_node.state_machine = self
		state_node.inimigo = inimigo_context
		state_node.cerebro = cerebro_context
	
	# Nós "agendamos" o início para o *próximo* frame
	_change_state.call_deferred(initial_state_node) #[cite: 78]
func _input(_event):
	if current_state != null:
		current_state.process_input(_event)

func _physics_process(_delta):
	if current_state != null:
		current_state.process_physics(_delta)

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
