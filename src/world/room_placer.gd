class_name RoomPlacer
extends Node3D


const ROOM_SIZE: Vector3 = Vector3(13.5, 0.0, 10.0)
const NEIGHBORS := [
	Vector2i.LEFT, Vector2i.RIGHT,
	Vector2i.UP, Vector2i.DOWN
]


static func get_room_size_2d() -> Vector2:
	return Vector2(ROOM_SIZE.x, ROOM_SIZE.z)


static func get_room_cell(world_pos: Vector3) -> Vector2i:
	var room_size: Vector2 = get_room_size_2d()
	var position_2d := Vector2(world_pos.x, world_pos.z)
	var offset_position := position_2d + room_size / 2.0
	return Vector2i((offset_position / room_size).floor())


func _on_layout_generator_layout_generated(grid: Dictionary[Vector2i, RoomData]) -> void:
	for child in get_children():
		child.queue_free()
		
	for cell in grid.keys():
		var room_data: RoomData = grid.get(cell)
		var scene: PackedScene = room_data.scene
		var room: Node3D = scene.instantiate()
		room.position = Vector3(cell.x, 0, cell.y) * ROOM_SIZE
		add_child(room)
		var exits: Array[Vector2i]
		for neighbor in NEIGHBORS:
			if grid.has(cell + neighbor):
				exits.append(neighbor)
		room.initialize.call_deferred(exits)
