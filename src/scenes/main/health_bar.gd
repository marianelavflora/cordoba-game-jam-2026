extends ProgressBar

func update_health(current: int, max_hp: int) -> void:
	max_value = max_hp
	value = current

	var health_ratio := float(current) / float(max_hp)

	if health_ratio > 0.6:
		self_modulate = Color.GREEN
	elif health_ratio > 0.3:
		self_modulate = Color.YELLOW
	else:
		self_modulate = Color.RED
