extends Area3D

@export var speed: float = 8.0      # velocidad reducida
@export var lifetime: float = 3.0
@export var damage: int = 1

var direction: Vector3 = Vector3.ZERO  # dirección fija al instanciar
var shooter: Node = null
var _time_alive: float = 0.0

func _ready() -> void:
	monitoring = true
	monitorable = true
	body_entered.connect(_on_body_entered)

	# Rotar la bala para que apunte en la dirección inicial
	if direction != Vector3.ZERO:
		look_at(global_position + direction, Vector3.UP)

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta
	_time_alive += delta
	if _time_alive >= lifetime:
		queue_free()

func _on_body_entered(body: Node) -> void:
	if body == null:
		return

	# Ignora al que disparó la bala
	if body == shooter:
		return

	# Daño al jugador
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(damage)
		queue_free()
		return

	# Daño a otros cuerpos
	if body.has_method("take_damage"):
		body.take_damage(damage)
		queue_free()

# ---------------- AUXILIAR ----------------
func set_direction_towards(target_node: Node3D) -> void:
	if target_node == null:
		return

	# Dirección solo horizontal (XZ)
	var dir = target_node.global_position - global_position
	dir.y = 0
	direction = dir.normalized()
