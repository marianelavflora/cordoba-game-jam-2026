extends Node

@export var enemy_scene: PackedScene = preload("res://src/characters/enemies/enemy_shooter.tscn")
## Margen desde las paredes/puertas para que el enemigo spawnee dentro de la habitación.
@export var room_margin: float = 2.5

func _ready() -> void:
	call_deferred("_spawn_once")

func _spawn_once() -> void:
	var players := get_tree().get_nodes_in_group("player")
	if players.is_empty():
		push_warning("EnemySpawner: no encontré ningún nodo en el grupo 'player'.")
		return

	var player := players[0] as Node3D
	if player == null:
		push_warning("EnemySpawner: el nodo del grupo 'player' no es Node3D.")
		return

	if enemy_scene == null:
		push_warning("EnemySpawner: enemy_scene es null.")
		return

	var spawn_pos: Vector3 = _get_spawn_position_inside_room(player.global_position)
	var enemy := enemy_scene.instantiate() as Node3D
	get_tree().current_scene.add_child(enemy)
	enemy.global_position = spawn_pos
	enemy.global_position.y = player.global_position.y


func _get_spawn_position_inside_room(world_pos: Vector3) -> Vector3:
	var room_size := RoomPlacer.get_room_size_2d()
	var half := room_size / 2.0
	var room_cell: Vector2i = Vector2i(
		floor((world_pos.x + half.x) / room_size.x),
		floor((world_pos.z + half.y) / room_size.y)
	)
	# Centro mundial de la habitación
	var room_center_x: float = room_cell.x * room_size.x
	var room_center_z: float = room_cell.y * room_size.y
	# Zona segura: interior de la habitación sin bordes (evita puertas)
	var half_safe_x: float = (room_size.x / 2.0) - room_margin
	var half_safe_z: float = (room_size.y / 2.0) - room_margin
	var x: float = room_center_x + randf_range(-half_safe_x, half_safe_x)
	var z: float = room_center_z + randf_range(-half_safe_z, half_safe_z)
	return Vector3(x, world_pos.y, z)
