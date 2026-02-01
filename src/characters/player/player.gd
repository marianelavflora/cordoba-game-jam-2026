extends CharacterBody3D

@export var move_speed: float = 6.0
@export var accel: float = 30.0
@export var friction: float = 40.0

@export var fire_rate: float = 6.0
@export var bullet_speed: float = 14.0

@onready var muzzle: Node3D = $Muzzle
@onready var audiosource: AudioStreamPlayer = $AudioStreamPlayer

const BULLET_SCENE: PackedScene = preload("res://src/characters/player/bullet.tscn")

var _cooldown: float = 0.0
var _aim_dir: Vector3 = Vector3(0, 0, 1) # fallback

@export var max_hp: int = 6
var hp: int = 6

func _ready() -> void:
	hp = max_hp
	add_to_group("player")

func take_damage(amount: int) -> void:
	hp = max(hp - amount, 0)
	print("Player HP:", hp)



	
func _physics_process(delta: float) -> void:
	# ---- MOVIMIENTO (WASD) ----
	var move_input: Vector2 = Input.get_vector(
		&"move_left", &"move_right",
		&"move_forward", &"move_backward"
	)

	var move_dir := Vector3(move_input.x, 0.0, move_input.y)
	var desired_velocity := Vector3.ZERO

	if move_dir.length() > 0.0:
		move_dir = move_dir.normalized()
		desired_velocity = move_dir * move_speed

		velocity.x = move_toward(velocity.x, desired_velocity.x, accel * delta)
		velocity.z = move_toward(velocity.z, desired_velocity.z, accel * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)
		velocity.z = move_toward(velocity.z, 0.0, friction * delta)

	velocity.y = 0.0
	move_and_slide()

	# ---- AIM por mouse (independiente del movimiento) ----
	var mouse_aim := _get_mouse_aim_dir()
	if mouse_aim != Vector3.ZERO:
		_aim_dir = mouse_aim

	# ---- DISPARO (Left Click via action "shoot") ----
	_cooldown = maxf(_cooldown - delta, 0.0)

	if Input.is_action_pressed(&"shoot"):
		_try_shoot()

func _get_mouse_aim_dir() -> Vector3:
	var cam := get_viewport().get_camera_3d()
	if cam == null:
		return Vector3.ZERO

	var mouse_pos := get_viewport().get_mouse_position()
	var ray_origin := cam.project_ray_origin(mouse_pos)
	var ray_dir := cam.project_ray_normal(mouse_pos)

	var plane := Plane(Vector3.UP, global_position.y)

	# intersects_ray devuelve Vector3 o null (Variant). Evitamos inferencia.
	var hit_variant = plane.intersects_ray(ray_origin, ray_dir)
	if hit_variant == null:
		return Vector3.ZERO

	var hit: Vector3 = hit_variant
	var to_hit: Vector3 = hit - global_position
	to_hit.y = 0.0

	if to_hit.length() == 0.0:
		return Vector3.ZERO

	return to_hit.normalized()


func _try_shoot() -> void:
	if _cooldown > 0.0:
		return
	if audiosource:
		audiosource.stop()
		audiosource.play()

	var bullet := BULLET_SCENE.instantiate()
	get_tree().current_scene.add_child(bullet)

	var spawn_offset := 0.35 # > radius (0.25) para salir de la cápsula
	bullet.global_position = muzzle.global_position + _aim_dir * spawn_offset
	bullet.direction = _aim_dir
	bullet.speed = bullet_speed

	# Pasamos quién disparó para ignorarlo en colisión
	bullet.shooter = self

	_cooldown = 1.0 / fire_rate
