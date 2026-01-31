extends CharacterBody3D

@export var move_speed: float = 6.0
@export var accel: float = 30.0
@export var friction: float = 40.0

func _physics_process(delta: float) -> void:
	# Movimiento tipo top-down en el plano X/Z (Y siempre 0)
	var input_dir: Vector2 = Input.get_vector(
		&"move_left", &"move_right",
		&"move_forward", &"move_backward"
	)

	var desired_velocity := Vector3(input_dir.x, 0.0, input_dir.y) * move_speed

	# Aceleración cuando hay input, fricción cuando no hay
	if input_dir.length() > 0.0:
		velocity.x = move_toward(velocity.x, desired_velocity.x, accel * delta)
		velocity.z = move_toward(velocity.z, desired_velocity.z, accel * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)
		velocity.z = move_toward(velocity.z, 0.0, friction * delta)

	velocity.y = 0.0
	move_and_slide()
