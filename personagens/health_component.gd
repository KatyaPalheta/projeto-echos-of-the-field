# [Script: health_component.gd]
# (Versão "Burra" - Corrigindo Bug #10)
extends Node
class_name HealthComponent

signal vida_mudou(vida_atual, vida_maxima)
signal morreu

@export var vida_maxima: float = 100.0
var vida_atual: float

@export var cena_dano_flutuante: PackedScene
@export_category("Cores do Dano")
@export var cor_dano_tomado: Color = Color.WHITE 
@export var cor_cura: Color = Color.GREEN_YELLOW 

func _ready() -> void:
	# A LÓGICA DO SAVEMANAGER FOI REMOVIDA DAQUI
	vida_atual = vida_maxima

# --- FUNÇÃO NOVA ---
# O player.gd vai chamar isso DEPOIS que a onda começar
func aplicar_bonus_de_vida(bonus: float):
	vida_maxima += bonus
	vida_atual = vida_maxima
	# Avisa a HUD sobre a nova vida máxima
	emit_signal("vida_mudou", vida_atual, vida_maxima)

func sofrer_dano(dano: float) -> void:
	if vida_atual == 0.0:
		return

	vida_atual = max(0.0, vida_atual - dano)
	_mostrar_dano_flutuante(dano, cor_dano_tomado)
	emit_signal("vida_mudou", vida_atual, vida_maxima)
	
	if vida_atual == 0.0:
		emit_signal("morreu")

func curar(quantidade: float) -> void:
	if vida_atual == 0.0:
		return
		
	vida_atual = min(vida_maxima, vida_atual + quantidade)
	_mostrar_dano_flutuante(quantidade, cor_cura)
	emit_signal("vida_mudou", vida_atual, vida_maxima)

func _mostrar_dano_flutuante(quantidade: float, cor: Color) -> void:
	if cena_dano_flutuante == null:
		push_warning("HealthComponent: Cena de Dano Flutuante não configurada!")
		return
		
	var dano_label = cena_dano_flutuante.instantiate()
	var dono = get_owner() as Node2D
	if dono == null:
		push_error("HealthComponent precisa ser filho de um Node2D!")
		return
		
	get_tree().current_scene.call_deferred("add_child", dano_label)
	dano_label.setup(quantidade, dono.global_position, cor)
