extends Camera3D


@onready var player: CharacterBody3D = $"../Player"

const HEIGHT := 5.0

var current_room: Vector2i = Vector2i.ZERO :
	set(value):
		current_room = value
		global_position = Vector3(
			current_room.x * RoomPlacer.ROOM_SIZE.x,
			HEIGHT,
			current_room.y * RoomPlacer.ROOM_SIZE.z
		)


func _process(delta: float) -> void:
	current_room = _get_current_room(player.global_position)
	print(current_room)
	
	
func _get_current_room(from_position: Vector3) -> Vector2i:
	var position_2d := Vector2(from_position.x, from_position.z)
	var room_size := RoomPlacer.get_room_size_2d()
	var offset_position := position_2d + room_size / 2.0
	return Vector2i((offset_position / room_size).floor())
