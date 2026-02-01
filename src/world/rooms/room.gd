extends Node3D

const WALL_TEXTURE_WAINSCOTING := "res://Texturas/wall_wainscoting.png"
const WALL_TEXTURE_WHITE := "res://Texturas/wall_mall.png"
const WALL_TEXTURE_BRICK := "res://Texturas/wall_brick.png"

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


func _ready() -> void:
	pass
	# Temporalmente deshabilitado para usar la textura del .tscn
	# _apply_random_wall_texture()


func _apply_random_wall_texture() -> void:
	var tex: Texture2D = load(WALL_TEXTURE_WAINSCOTING) as Texture2D
	if tex == null:
		tex = load(WALL_TEXTURE_WHITE) as Texture2D
	if tex == null:
		return
	var base_material: Material = wall_left.material_override
	if base_material == null:
		return
	var mat: StandardMaterial3D = base_material.duplicate() as StandardMaterial3D
	if mat == null:
		return
	mat.albedo_texture = tex
	mat.albedo_color = Color.WHITE
	for wall in walls.values():
		wall.material_override = mat


func initialize(exits: Array[Vector2i]) -> void:
	# Obtener la celda de esta habitación
	var my_cell := RoomPlacer.get_room_cell(global_position)
	
	for wall_dir in walls.keys():
		if wall_dir in exits:
			# Hay una conexión en esta dirección
			# Solo mantener el blocker si somos la habitación "mayor"
			var neighbor_cell: Vector2i = my_cell + wall_dir
			var should_keep_blocker := _should_keep_blocker(my_cell, neighbor_cell)
			
			if not should_keep_blocker:
				# Eliminar el blocker de esta puerta (el vecino lo maneja)
				match wall_dir:
					Vector2i.LEFT:
						if $Walls/WallLeft/DoorHole.has_node("DoorBlocker"):
							$Walls/WallLeft/DoorHole/DoorBlocker.queue_free()
					Vector2i.RIGHT:
						if $Walls/WallRight/DoorHole.has_node("DoorBlocker"):
							$Walls/WallRight/DoorHole/DoorBlocker.queue_free()
					Vector2i.DOWN:
						if $Walls/WallBottom/DoorHole.has_node("DoorBlocker"):
							$Walls/WallBottom/DoorHole/DoorBlocker.queue_free()
					Vector2i.UP:
						if $Walls/WallTop/DoorHole.has_node("DoorBlocker"):
							$Walls/WallTop/DoorHole/DoorBlocker.queue_free()
		else:
			# No hay conexión, eliminar toda la puerta
			match wall_dir:
				Vector2i.LEFT: 
					$Walls/WallLeft/DoorHole.queue_free()
				Vector2i.RIGHT: 
					$Walls/WallRight/DoorHole.queue_free()
				Vector2i.DOWN: 
					$Walls/WallBottom/DoorHole.queue_free()
				Vector2i.UP: 
					$Walls/WallTop/DoorHole.queue_free()

func _should_keep_blocker(my_cell: Vector2i, neighbor_cell: Vector2i) -> bool:
	# Solo mantener el blocker si nuestra celda es "mayor" que la vecina
	# Esto asegura que solo haya un blocker por conexión
	if my_cell.y > neighbor_cell.y:
		return true
	elif my_cell.y == neighbor_cell.y and my_cell.x > neighbor_cell.x:
		return true
	return false
