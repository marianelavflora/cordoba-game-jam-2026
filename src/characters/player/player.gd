extends CharacterBody3D

@export var move_speed: float = 6.0
@export var accel: float = 30.0
@export var friction: float = 40.0

@export var fire_rate: float = 6.0
@export var bullet_speed: float = 14.0

@onready var muzzle: Node3D = $Muzzle
@onready var audio_shoot: AudioStreamPlayer = $AudioShoot
@onready var audio_hit: AudioStreamPlayer = $AudioHit
const BULLET_SCENE: PackedScene = preload("res://src/characters/player/bullet.tscn")

@export var rotation_speed: float = 10.0

var _cooldown: float = 0.0
var _aim_dir: Vector3 = Vector3(0, 0, 1) # fallback


@onready var health_bar := get_tree().current_scene.get_node("CanvasLayer1/HealthBar")



@export var max_hp: int = 6
var hp: int = 6
var is_dead: bool = false
func _ready() -> void:
	hp = max_hp
	add_to_group("player")
	if health_bar:
		health_bar.update_health(hp, max_hp)



func take_damage(amount: int) -> void:
	hp = max(hp - amount, 0)
	
	if audio_hit:
		audio_hit.play() # no stop → mejor sensación de impacto
	print("Player HP:", hp)
	if health_bar:
		health_bar.update_health(hp, max_hp)
	if hp <= 0:
		die()

func die() -> void:
	is_dead = true
	velocity = Vector3.ZERO
	set_physics_process(false) 
	set_process(false)         

	# Mostrar cartel
	var ui := get_tree().current_scene.get_node("CanvasLayer1/GameOverLabel")
	if ui:
		ui.visible = true
		



	
func _physics_process(delta: float) -> void:
	if is_dead:
		return
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

	_rotate_towards_aim(delta)
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
	if audio_shoot:
		audio_shoot.stop()
		audio_shoot.play()

	var bullet := BULLET_SCENE.instantiate()
	get_tree().current_scene.add_child(bullet)

	var spawn_offset := 0.35 # > radius (0.25) para salir de la cápsula
	bullet.global_position = muzzle.global_position + _aim_dir * spawn_offset
	bullet.direction = _aim_dir
	bullet.speed = bullet_speed

	# Pasamos quién disparó para ignorarlo en colisión
	bullet.shooter = self

	_cooldown = 1.0 / fire_rate

func _rotate_towards_aim(delta: float) -> void:
	if _aim_dir == Vector3.ZERO:
		return

	var target_angle := atan2(_aim_dir.x, _aim_dir.z)
	var current_angle := rotation.y

	rotation.y = lerp_angle(
		current_angle,
		target_angle,
		rotation_speed * delta
	)
