extends Control

const CELL_SIZE := Vector2i(16, 16)

var layout: Dictionary = {}
var current_room: Vector2i = Vector2i.ZERO


func _on_layout_generator_layout_generated(grid: Dictionary[Vector2i, RoomData]) -> void:
	layout = grid
	queue_redraw()


func _draw() -> void:
	# Background so minimap is visible over the 3D scene
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.75, 0.75, 0.75, 0.9))
	
	if layout.is_empty():
		return
		
	for cell in layout:
		var rect_pos := Vector2((cell - current_room) * CELL_SIZE) + size / 2.0 - Vector2(CELL_SIZE) / 2.0
		var color := Color.WHITE if cell != current_room else Color.RED
		draw_rect(Rect2(rect_pos, CELL_SIZE), color)


func _on_camera_3d_player_room_changed(new_room: Vector2i) -> void:
	current_room = new_room
	queue_redraw()
