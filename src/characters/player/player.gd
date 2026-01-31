extends CharacterBody3D

@export var move_speed: float = 6.0
@export var accel: float = 30.0
@export var friction: float = 40.0

@export var fire_rate: float = 6.0
@export var bullet_speed: float = 14.0

@onready var muzzle: Node3D = $Muzzle

const BULLET_SCENE: PackedScene = preload("res://src/characters/player/bullet.tscn")

var _cooldown: float = 0.0
var _aim_dir: Vector3 = Vector3(0, 0, 1)

func _physics_process(delta: float) -> void:
	# ---- MOVIMIENTO ----
	var move_input: Vector2 = Input.get_vector(
		&"move_left", &"move_right",
		&"move_forward", &"move_backward"
	)

	var move_dir := Vector3(move_input.x, 0.0, move_input.y)

	if move_dir.length() > 0.0:
		move_dir = move_dir.normalized()
		_aim_dir = move_dir

	var desired_velocity := move_dir * move_speed

	if move_input.length() > 0.0:
		velocity.x = move_toward(velocity.x, desired_velocity.x, accel * delta)
		velocity.z = move_toward(velocity.z, desired_velocity.z, accel * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)
		velocity.z = move_toward(velocity.z, 0.0, friction * delta)

	velocity.y = 0.0
	move_and_slide()

	# ---- DISPARO ----
	_cooldown = maxf(_cooldown - delta, 0.0)

	if Input.is_action_pressed(&"shoot"):
		_try_shoot()

func _try_shoot() -> void:
	if _cooldown > 0.0:
		return

	var bullet: Area3D = BULLET_SCENE.instantiate() as Area3D
	get_tree().current_scene.add_child(bullet)

	bullet.global_position = muzzle.global_position
	bullet.direction = _aim_dir
	bullet.speed = bullet_speed

	_cooldown = 1.0 / fire_rate
