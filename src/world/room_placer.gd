class_name RoomPlacer
extends Node3D


const ROOM_SIZE: Vector3 = Vector3(13.5, 0.0, 10.0)



static func get_room_size_2d() -> Vector2:
	return Vector2(ROOM_SIZE.x, ROOM_SIZE.z)


func _on_layout_generator_layout_generated(grid: Dictionary[Vector2i, RoomData]) -> void:
	for child in get_children():
		child.queue_free()
		
	for cell in grid.keys():
		var room_data: RoomData = grid.get(cell)
		var scene: PackedScene = room_data.scene
		var room: Node3D = scene.instantiate()
		room.position = Vector3(cell.x, 0, cell.y) * ROOM_SIZE
		add_child(room)
