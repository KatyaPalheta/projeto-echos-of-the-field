# [Script: hud.gd]
extends CanvasLayer

# Pega as referências das três barras
@onready var barra_vida: TextureProgressBar = $BarraVida
@onready var barra_energia: TextureProgressBar = $BarraEnergia
@onready var onda_label: Label = $OndaLabel
@onready var onda_timer: Timer = $OndaTimer

@onready var vida_label: Label = $VidaLabel
@onready var energia_label: Label = $EnergiaLabel 

@onready var log_container: VBoxContainer = $LogContainer
@onready var contador_label: Label = $ContadorLabel

@onready var estrela1: TextureRect = $CargasCuraContainer/Estrela1
@onready var estrela2: TextureRect = $CargasCuraContainer/Estrela2
@onready var estrela3: TextureRect = $CargasCuraContainer/Estrela3

@export var tex_estrela_cheia: Texture2D
@export var tex_estrela_vazia: Texture2D

@export var cena_icone_skill: PackedScene
# Usamos apenas a linha superior para todos os 20 slots
@onready var linha_superior: HBoxContainer = $ContainerSkills/MarginContainer/LinhaSuperior 
# O @onready var linha_inferior foi removido

var skill_slots: Array[Node] = []

func _ready():
	Logger.log_updated.connect(_on_log_updated)
	GameManager.stats_atualizadas.connect(atualizar_contador_inimigos)
	
	criar_slots_dinamicamente()
	if SaveManager != null:
		SaveManager.upgrades_da_partida_mudaram.connect(_on_upgrades_mudaram)
	
	call_deferred("_on_upgrades_mudaram")
	
	# Garante que a HUD comece limpa
	_resetar_slots_de_skill()
	
	call_deferred("_on_upgrades_mudaram")

func criar_slots_dinamicamente():
	if cena_icone_skill == null:
		push_error("HUD: Faltou arrastar a 'IconeSkill.tscn' no Inspetor!")
		return
		
	# Vamos criar 20 slots
	for i in range(20):
		var novo_slot = cena_icone_skill.instantiate()
		
		# Adiciona na lista de controle
		skill_slots.append(novo_slot)
		
		# ADICIONA TUDO NA LINHA SUPERIOR (Linha Única)
		linha_superior.add_child(novo_slot)
			
		# Garante que nasce resetado
		novo_slot.resetar_slot()

func atualizar_vida(vida_atual: float, vida_maxima: float) -> void:
	barra_vida.max_value = vida_maxima
	vida_label.text = str(int(vida_atual))
	barra_vida.value = vida_atual

func atualizar_energia(energia_atual: float, energia_maxima: float):
	barra_energia.max_value = energia_maxima
	energia_label.text = str(int(energia_atual))
	barra_energia.value = energia_atual

func _on_log_updated(messages: Array[String]):
	for child in log_container.get_children():
		child.queue_free()
	for msg in messages:
		var new_label = Label.new()
		new_label.text = msg
		log_container.add_child(new_label)

func atualizar_cargas_cura(cargas_restantes: int):
	estrela1.texture = tex_estrela_cheia if cargas_restantes >= 1 else tex_estrela_vazia
	estrela2.texture = tex_estrela_cheia if cargas_restantes >= 2 else tex_estrela_vazia
	estrela3.texture = tex_estrela_cheia if cargas_restantes == 3 else tex_estrela_vazia

func atualizar_contador_inimigos(mortos: int, total: int, _onda: int):
	
	contador_label.text = "%s / %s" % [mortos, total] 

	if mortos == 0:
		onda_label.text = "Onda %s" % _onda
		onda_label.visible = true
		onda_timer.start()

func _on_onda_timer_timeout() -> void:
	onda_label.visible = false

func _on_player_vida_atualizada(vida_atual: float, vida_maxima: float) -> void:
	atualizar_vida(vida_atual, vida_maxima)

func _on_player_energia_mudou(energia_atual: float, energia_maxima: float) -> void:
	atualizar_energia(energia_atual, energia_maxima)

func _on_player_cargas_cura_mudou(cargas_restantes: int) -> void:
	atualizar_cargas_cura(cargas_restantes)

func _resetar_slots_de_skill():
	for slot in skill_slots:
		slot.resetar_slot()

func _on_upgrades_mudaram():
	if SaveManager == null or SaveManager.dados_atuais == null:
		return

	var upgrades_no_save: Dictionary = SaveManager.dados_atuais.upgrades_da_partida
	
	_resetar_slots_de_skill()
	
	var slot_idx: int = 0
	
	for id_upgrade in upgrades_no_save.keys():
		if slot_idx >= skill_slots.size():
			push_warning("HUD: Acabaram os slots de skill! (Mais de 20 upgrades)")
			break 
		
		var contador: int = upgrades_no_save[id_upgrade]
		
		var slot_atual: Node = skill_slots[slot_idx]
		
		slot_atual.setup_slot(id_upgrade)
		slot_atual.atualizar_contador(contador)
		
		slot_idx += 1
