extends Node
class_name HealthComponent

# --- SINAIS ---
# Sinal emitido quando a vida muda (para o HUD de corações)
signal vida_mudou(vida_atual, vida_maxima)
# Sinal emitido quando a vida chega a zero
signal morreu

# --- VARIÁVEIS DE VIDA ---
@export var vida_maxima: float = 100.0
var vida_atual: float

# --- O "NUMEROZINHO" ---
# Aqui vamos linkar a cena que você ACABOU de criar
@export var cena_dano_flutuante: PackedScene

@export_category("Cores do Dano")
@export var cor_dano_tomado: Color = Color.WHITE # Cor padrão (branca)
@export var cor_cura: Color = Color.GREEN_YELLOW # Cor para cura

func _ready() -> void:
	vida_atual = vida_maxima


# Função principal para causar dano
func sofrer_dano(dano: float) -> void:
	# Não faz nada se já estiver morto
	if vida_atual == 0.0:
		return

	# Aplica o dano e garante que não passe de zero
	vida_atual = max(0.0, vida_atual - dano)
	
	# Chama a função para mostrar o "numerozinho"
	_mostrar_dano_flutuante(dano, cor_dano_tomado)
	
	# Avisa o HUD e o script do dono (Slime/Player) que a vida mudou
	emit_signal("vida_mudou", vida_atual, vida_maxima)
	
	if vida_atual == 0.0:
		emit_signal("morreu")

# Função para cura (para o Botão B)
func curar(quantidade: float) -> void:
	# Não cura quem já está morto
	if vida_atual == 0.0:
		return
		
	vida_atual = min(vida_maxima, vida_atual + quantidade)
	_mostrar_dano_flutuante(quantidade, cor_cura)
	emit_signal("vida_mudou", vida_atual, vida_maxima)

# --- FUNÇÃO PRIVADA ---

# Esta função cria o "numerozinho"
func _mostrar_dano_flutuante(quantidade: float, cor: Color) -> void:
	# Se a cena não foi configurada no inspetor, não faz nada
	if cena_dano_flutuante == null:
		push_warning("HealthComponent: Cena de Dano Flutuante não configurada!")
		return
		
	# 1. Cria uma instância da cena do "numerozinho"
	var dano_label = cena_dano_flutuante.instantiate()
	
	# 2. Pega o "dono" deste componente (o Player ou o Slime)
	var dono = get_owner() as Node2D
	if dono == null:
		push_error("HealthComponent precisa ser filho de um Node2D!")
		return
		
	# 3. Adiciona o "numerozinho" à cena principal
	get_tree().current_scene.call_deferred("add_child", dano_label)
	
	# 4. Chama a função setup() que criamos no dano_flutuante.gd
	#    e passa a 'quantidade' E a 'cor' (agora corretas!)
	dano_label.setup(quantidade, dono.global_position, cor)
