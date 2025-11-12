# [Script: EstadoPlayer.gd]
extends Node
class_name EstadoPlayer

# Referência para o Gerenciador de Estados (para podermos_mudar_ de estado)
var state_machine = null

# Referência para o nó do Player (para acessarmos 'velocity', 'animacao', etc.)
# Usaremos 'player' para evitar conflito com a variável 'owner' do Godot.
var player = null

# Esta função é chamada (pelo StateMachine) quando entramos neste estado.
func enter():
	pass

# Esta função é chamada (pelo StateMachine) quando saímos deste estado.
func exit():
	pass

# Esta função roda a cada frame (equivalente ao _input)
func process_input(_event: InputEvent):
	pass

# Esta função roda a cada frame de física (equivalente ao _physics_process)
func process_physics(_delta: float):
	pass
