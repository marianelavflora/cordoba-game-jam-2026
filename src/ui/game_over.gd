extends CanvasLayer

var can_restart: bool = true

func _ready() -> void:
	# Pausar el juego
	get_tree().paused = true

func _input(event: InputEvent) -> void:
	if can_restart and event.is_action_pressed("ui_accept"):  # SPACE o ENTER
		_restart_game()

func _restart_game() -> void:
	# Prevenir múltiples reinicios
	can_restart = false
	
	# Despausar antes de recargar
	get_tree().paused = false
	
	# Eliminar esta pantalla primero
	queue_free()
	
	# Recargar la escena principal
	get_tree().reload_current_scene()
