extends Control


const CELL_SIZE := Vector2i(16, 16)

var layout: Dictionary[Vector2i, RoomData]
var current_room: Vector2i = Vector2i.ZERO


func _on_layout_generator_layout_generated(grid: Dictionary[Vector2i, RoomData]) -> void:
	layout = grid
	queue_redraw()
	
	
func _draw() -> void:
	for cell in layout:
		draw_rect(
			Rect2(Vector2((cell - current_room) * CELL_SIZE) + size / 2.0 - Vector2(CELL_SIZE) / 2.0, CELL_SIZE),
			Color.WHITE if cell != current_room else Color.RED
		)


func _on_camera_3d_player_room_changed(new_room: Vector2i) -> void:
	current_room = new_room
	queue_redraw()
