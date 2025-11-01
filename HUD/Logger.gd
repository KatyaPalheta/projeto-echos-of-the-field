extends Node

# O sinal que o HUD vai ouvir
signal log_updated(messages)

# Nosso limite de 3 mensagens
const MAX_MESSAGES = 3
var log_history: Array[String] = []

# Esta é a função "pública" que qualquer script vai chamar
func log(message: String):
	# 1. Adiciona a nova mensagem no TOPO da lista
	log_history.push_front(message)
	
	# 2. Se a lista for maior que 3, remove a última (a mais antiga)
	if log_history.size() > MAX_MESSAGES:
		log_history.pop_back()
		
	# 3. Avisa ao HUD que a lista foi atualizada
	emit_signal("log_updated", log_history)
