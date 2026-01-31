extends Area3D

@export var speed: float = 10.0
@export var lifetime: float = 2.0
@export var damage: int = 1

var direction: Vector3 = Vector3.ZERO
var _t: float = 0.0

func _ready() -> void:
	monitoring = true
	monitorable = true
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta

	_t += delta
	if _t >= lifetime:
		queue_free()

func _on_body_entered(body: Node) -> void:
	if body.has_method("take_damage"):
		body.call("take_damage", damage)
	queue_free()
