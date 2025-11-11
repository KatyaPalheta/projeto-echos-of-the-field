# [Script: EstadoInimigo.gd]
extends Node
class_name EstadoInimigo

# Referência para o Gerenciador de Estados (para podermos _mudar_ de estado)
var state_machine = null

# Referência para o nó do Inimigo (para acessarmos 'velocity', 'animacao', etc.)
# Usaremos 'inimigo' para o corpo (inimigo_base) e 'cerebro' para a lógica (smile)
var inimigo = null
var cerebro = null # (Ex: O script smile.gd, para pegar 'jump_cooldown')

# Esta função é chamada (pelo StateMachine) quando entramos neste estado.
func enter():
	pass

# Esta função é chamada (pelo StateMachine) quando saímos deste estado.
func exit():
	pass

# Esta função roda a cada frame (equivalente ao _input)
func process_input(event: InputEvent):
	pass

# Esta função roda a cada frame de física (equivalente ao _physics_process)
func process_physics(delta: float):
	pass
