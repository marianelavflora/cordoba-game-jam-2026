extends CharacterBody3D

# ---------------- CONFIGURACIÓN ----------------
@export var run_speed: float = 2.5       # velocidad reducida
@export var walk_speed: float = 1.2      # velocidad reducida
@export var circle_speed: float = 1.2
@export var circle_move_speed: float = 0.8
@export var circle_radius: float = 2.0
@export var max_health: int = 40

# Daño por contacto
@export var contact_damage: int = 2
@export var damage_interval: float = 0.8

# Disparo de balas
@export var bullet_scene: PackedScene
@export var min_shoot_interval: float = 0.7
@export var max_shoot_interval: float = 7.0

# Intervalo aleatorio de cambio de estado
@export var min_state_time: float = 1.0
@export var max_state_time: float = 3.0

# ---------------- VARIABLES INTERNAS ----------------
var player: Node3D
var health: int
var damage_cooldown: float = 0.0

var state_timer: float = 0.0
var state_duration: float = 0.0
var current_state: int = 0 # 0=correr, 1=caminar, 2=circular+disparo

# Circular
var clockwise: bool = true
var circle_center: Vector3
var circle_angle: float = 0.0
var direction_timer: float = 0.0
var next_direction_change: float = 0.0

# Disparo
var shoot_timer: float = 0.0
var next_shoot_time: float = 0.0

# NODOS
@onready var mesh_alive: MeshInstance3D = $MeshAlive
@onready var mesh_dead: MeshInstance3D = $MeshDead
@onready var collision: CollisionShape3D = $CollisionShape3D

# ---------------- READY ----------------
func _ready():
	health = max_health
	mesh_dead.visible = false
	player = get_tree().get_first_node_in_group("player")

	_set_new_state()
	next_shoot_time = randf_range(min_shoot_interval, max_shoot_interval)

# ---------------- PHYSICS PROCESS ----------------
func _physics_process(delta: float) -> void:
	if health <= 0 or player == null:
		return

	# cooldown de daño
	damage_cooldown = maxf(damage_cooldown - delta, 0.0)

	# -------- CAMBIO DE ESTADO --------
	state_timer += delta
	if state_timer >= state_duration:
		_set_new_state()

	# -------- MOVIMIENTO SEGÚN ESTADO --------
	match current_state:
		0: _chase_movement(run_speed)
		1: _chase_movement(walk_speed)
		2: _circle_movement(delta)

	move_and_slide()

	# -------- DAÑO POR CONTACTO --------
	if damage_cooldown <= 0.0:
		for i in range(get_slide_collision_count()):
			var col := get_slide_collision(i).get_collider()
			if col != null and col.is_in_group("player"):
				if col.has_method("take_damage"):
					col.take_damage(contact_damage)
				damage_cooldown = damage_interval
				break

	# -------- DISPARO DE BALAS (solo en estado circular) --------
	if current_state == 2 and bullet_scene != null:
		shoot_timer += delta
		if shoot_timer >= next_shoot_time:
			_shoot_bullet()
			shoot_timer = 0.0
			next_shoot_time = randf_range(min_shoot_interval, max_shoot_interval)

# ---------------- FUNCIONES DE MOVIMIENTO ----------------
func _chase_movement(speed: float) -> void:
	var dir = player.global_position - global_position
	dir.y = 0
	velocity = dir.normalized() * speed

func _circle_movement(delta: float) -> void:
	if circle_center == Vector3():
		circle_center = global_position
		circle_angle = 0.0
		direction_timer = 0.0
		next_direction_change = randf_range(min_state_time, max_state_time)

	direction_timer += delta
	if direction_timer >= next_direction_change:
		direction_timer = 0.0
		clockwise = !clockwise
		next_direction_change = randf_range(min_state_time, max_state_time)

	var sign := 1.0 if clockwise else -1.0
	circle_angle += circle_speed * sign * delta

	var offset := Vector3(cos(circle_angle), 0, sin(circle_angle)) * circle_radius
	var target := circle_center + offset
	var dir := target - global_position
	dir.y = 0
	velocity = dir.normalized() * circle_move_speed

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

# ---------------- DISPARO ----------------
func _shoot_bullet() -> void:
	var bullet = bullet_scene.instantiate() as Area3D
	if bullet == null:
		return

	bullet.global_transform.origin = global_position + Vector3(0, 0.5, 1.5)
	bullet.shooter = self

	# Dirección hacia el jugador (solo horizontal)
	if player != null and bullet.has_method("set_direction_towards"):
		bullet.set_direction_towards(player)

	get_tree().current_scene.add_child(bullet)

# ---------------- AUXILIARES ----------------
func _set_new_state() -> void:
	state_timer = 0.0
	state_duration = randf_range(min_state_time, max_state_time)
	current_state = randi() % 3  # 0=correr,1=caminar,2=circular+disparo

	if current_state == 2:
		circle_center = global_position
		circle_angle = 0.0
		direction_timer = 0.0
		next_direction_change = randf_range(min_state_time, max_state_time)
