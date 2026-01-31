extends Area3D

@export var speed: float = 14.0
@export var lifetime: float = 1.2
@export var damage: int = 1

var direction: Vector3 = Vector3.ZERO
var _time_alive: float = 0.0

func _ready() -> void:
	monitoring = true
	monitorable = true
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta

	_time_alive += delta
	if _time_alive >= lifetime:
		queue_free()

func _on_body_entered(body: Node) -> void:
	if body.has_method("take_damage"):
		body.call("take_damage", damage)
	queue_free()
