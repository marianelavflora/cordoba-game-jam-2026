extends CharacterBody3D

@export var walk_speed: float = 0.8
@export var circle_speed: float = 1.5          # velocidad angular
@export var circle_move_speed: float = 0.8     # velocidad lineal al orbitar
@export var circle_radius: float = 1.5
@export var state_time: float = 3.0
@export var max_health: int = 7

# ---- CAMBIO DE DIRECCIÓN ALEATORIO ----
@export var min_direction_time: float = 1.0
@export var max_direction_time: float = 4.0

var clockwise: bool = true
var direction_timer: float = 0.0
var next_direction_change: float = 0.0

# ---- DAÑO POR CONTACTO ----
@export var contact_damage: int = 1
@export var damage_interval: float = 0.8
var damage_cooldown: float = 0.0

var health: int
var player: Node3D

var is_circling: bool = false
var state_timer: float = 0.0
var circle_angle: float = 0.0
var circle_center: Vector3

@onready var mesh_alive: MeshInstance3D = $MeshAlive
@onready var mesh_dead: MeshInstance3D = $MeshDead
@onready var collision: CollisionShape3D = $CollisionShape3D

func _ready():
	health = max_health
	mesh_dead.visible = false
	player = get_tree().get_first_node_in_group("player")

	# primer intervalo aleatorio
	next_direction_change = randf_range(min_direction_time, max_direction_time)

func _physics_process(delta: float) -> void:
	if health <= 0 or player == null:
		return

	# cooldown del daño
	damage_cooldown = maxf(damage_cooldown - delta, 0.0)

	# -------- CAMBIO DE ESTADO (perseguir / circular) --------
	state_timer += delta
	if state_timer >= state_time:
		state_timer = 0.0
		is_circling = !is_circling

		if is_circling:
			circle_center = global_position
			circle_angle = 0.0
			direction_timer = 0.0
			next_direction_change = randf_range(min_direction_time, max_direction_time)

	# -------- CAMBIO DE DIRECCIÓN DE GIRO --------
	if is_circling:
		direction_timer += delta
		if direction_timer >= next_direction_change:
			direction_timer = 0.0
			clockwise = !clockwise
			next_direction_change = randf_range(min_direction_time, max_direction_time)

	if is_circling:
		_circle_movement(delta)
	else:
		_chase_movement()

	move_and_slide()

	# -------- DAÑO POR CONTACTO --------
	if damage_cooldown > 0.0:
		return

	for i in range(get_slide_collision_count()):
		var collision_info := get_slide_collision(i)
		var body := collision_info.get_collider()

		if body != null and body.is_in_group("player"):
			body.take_damage(contact_damage)
			damage_cooldown = damage_interval
			break

# ---------------- MOVIMIENTO ----------------

func _chase_movement() -> void:
	var direction = player.global_position - global_position
	direction.y = 0
	velocity = direction.normalized() * walk_speed

func _circle_movement(delta: float) -> void:
	var dir_sign := 1.0 if clockwise else -1.0
	circle_angle += circle_speed * dir_sign * delta

	var offset := Vector3(
		cos(circle_angle),
		0,
		sin(circle_angle)
	) * circle_radius

	var target_pos := circle_center + offset
	var direction := target_pos - global_position
	direction.y = 0

	velocity = direction.normalized() * circle_move_speed

# ---------------- VIDA ----------------

func take_damage(amount: int) -> void:
	if health <= 0:
		return

	health -= amount
	if health <= 0:
		die()

func die() -> void:
	mesh_alive.visible = false
	mesh_dead.visible = true
	collision.disabled = true

	await get_tree().create_timer(2.0).timeout
	queue_free()
