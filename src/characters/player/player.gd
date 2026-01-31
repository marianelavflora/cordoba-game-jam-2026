extends CharacterBody3D


const SPEED := 5.0
const MOUSE_SENSITIVITY := 0.002

@onready var camera: Camera3D = $Camera3D


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	var input_dir := Input.get_vector(
		&"move_left", &"move_right", 
		&"move_forward", &"move_backward"
	)
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	_update_velocity(direction)
	move_and_slide()


func _update_velocity(dir: Vector3) -> void:
	velocity.x = lerpf(velocity.x, dir.x * SPEED, 0.2)
	velocity.z = lerpf(velocity.z, dir.z * SPEED, 0.2)
