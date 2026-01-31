class_name RoomPlacer
extends Node3D

@onready var camera_3d: Camera3D = $"../Camera3D"

const ROOM_SIZE: Vector3 = Vector3(13.5, 0.0, 10.0)


func _on_layout_generator_layout_generated(grid: Dictionary[Vector2i, RoomData]) -> void:
	for child in get_children():
		child.queue_free()
		
	for cell in grid.keys():
		var room_data: RoomData = grid.get(cell)
		var scene: PackedScene = room_data.scene
		var room: Node3D = scene.instantiate()
		room.position = Vector3(cell.x, 0, cell.y) * ROOM_SIZE
		add_child(room)


func _process(delta: float) -> void:
	camera_3d.position.x -= Input.get_axis(&"move_right", &"move_left")
	camera_3d.position.z -= Input.get_axis(&"move_backward", &"move_forward")
