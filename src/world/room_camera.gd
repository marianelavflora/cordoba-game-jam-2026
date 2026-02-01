extends Camera3D


signal player_room_changed(new_room: Vector2i)

@export var player: CharacterBody3D

const HEIGHT := 5.0

var current_room: Vector2i = Vector2i.ZERO :
	set(value):
		if current_room == value:
			return
		current_room = value
		var tween: Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
		tween.tween_property(
			self, "global_position",
			Vector3(
				current_room.x * RoomPlacer.ROOM_SIZE.x,
				HEIGHT,
				current_room.y * RoomPlacer.ROOM_SIZE.z + 0.85
			), 0.1
		)
		player_room_changed.emit(current_room)
		#global_position = global_position.lerp(, 0.25)


func _process(delta: float) -> void:
	if is_instance_valid(player):
		current_room = _get_current_room(player.global_position)


func _get_current_room(from_position: Vector3) -> Vector2i:
	var position_2d := Vector2(from_position.x, from_position.z)
	var room_size := RoomPlacer.get_room_size_2d()
	var offset_position := position_2d + room_size / 2.0
	return Vector2i((offset_position / room_size).floor())
