extends CharacterBody3D

@export var walk_speed: float = 2.0
@export var run_speed: float = 4.0
@export var state_time: float = 3.0
@export var max_health: int = 7

# ---- DAÑO POR CONTACTO ----
@export var contact_damage: int = 1
@export var damage_interval: float = 0.8
var damage_cooldown: float = 0.0

var health: int
var player: Node3D

var is_running: bool = false
var state_timer: float = 0.0

@onready var mesh_alive: MeshInstance3D = $MeshAlive
@onready var mesh_dead: MeshInstance3D = $MeshDead
@onready var collision: CollisionShape3D = $CollisionShape3D

func _ready():
	health = max_health
	mesh_dead.visible = false
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	if health <= 0 or player == null:
		return

	# cooldown del daño
	damage_cooldown = maxf(damage_cooldown - delta, 0.0)

	# CAMBIO DE ESTADO CADA X SEGUNDOS
	state_timer += delta
	if state_timer >= state_time:
		state_timer = 0.0
		is_running = !is_running

	var speed = run_speed if is_running else walk_speed

	# DIRECCIÓN AL JUGADOR (SIN ROTAR)
	var direction = player.global_position - global_position
	direction.y = 0
	direction = direction.normalized()

	# MOVIMIENTO
	velocity = direction * speed
	move_and_slide()

	# ---- DAÑO POR CONTACTO USANDO COLLISIONS ----
	if damage_cooldown > 0.0:
		return

	for i in range(get_slide_collision_count()):
		var collision_info := get_slide_collision(i)
		var body := collision_info.get_collider()

		if body != null and body.is_in_group("player"):
			body.take_damage(contact_damage)
			damage_cooldown = damage_interval
			break

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
