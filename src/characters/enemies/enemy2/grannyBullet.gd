extends Area3D

@export var speed: float = 4.0
var direction: Vector3 = Vector3.ZERO
@export var lifetime: float = 1.4  # auto-destrucción si no impacta

@onready var mesh: MeshInstance3D = $Node3D/MeshInstance3D

func _ready():
	# Conectamos la señal de colisión
	connect("body_entered", Callable(self, "_on_body_entered"))

	# Auto-destrucción
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func set_target(target: Node3D) -> void:
	if target == null:
		return

	# Dirección en XZ manteniendo altura actual
	var target_pos = target.global_position
	target_pos.y = global_position.y
	direction = (target_pos - global_position).normalized()

func _physics_process(delta: float) -> void:
	if direction == Vector3.ZERO:
		return

	# Mover proyectil en línea recta
	global_translate(direction * speed * delta)

# ---------------- COLISION ----------------
func _on_body_entered(body: Node) -> void:
	# Verificamos que sea el jugador
	if body.is_in_group("player"):
		# Aquí podés aplicar daño si querés
		if body.has_method("take_damage"):
			body.take_damage(1)  # ejemplo: daño de 1

		# Destruir la bala
		queue_free()
