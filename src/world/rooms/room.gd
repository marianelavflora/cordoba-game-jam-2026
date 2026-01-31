extends Node3D


@onready var walls: Dictionary[Vector2i, CSGBox3D] = {
	Vector2i.LEFT: $Walls/WallLeft,
	Vector2i.RIGHT: $Walls/WallRight,
	Vector2i.DOWN: $Walls/WallBottom,
	Vector2i.UP: $Walls/WallTop
}

@onready var wall_left: CSGBox3D = $Walls/WallLeft
@onready var wall_right: CSGBox3D = $Walls/WallRight
@onready var wall_bottom: CSGBox3D = $Walls/WallBottom
@onready var wall_top: CSGBox3D = $Walls/WallTop


func initialize(exits: Array[Vector2i]) -> void:
	for wall_dir in walls.keys():
		if wall_dir in exits: 
			continue
		match wall_dir:
			Vector2i.LEFT: 
				$Walls/WallLeft/DoorHole.queue_free()
			Vector2i.RIGHT: 
				$Walls/WallRight/DoorHole.queue_free()
			Vector2i.DOWN: 
				$Walls/WallBottom/DoorHole.queue_free()
			Vector2i.UP: 
				$Walls/WallTop/DoorHole.queue_free()
