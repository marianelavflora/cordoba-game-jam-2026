class_name LayoutGenerator
extends Node


signal layout_generated(grid: Dictionary[Vector2i, RoomData])

## Parámetros de la generación.
const ROTATION_WEIGHTS := {
	PI * 0.5: 1,
	-PI * 0.5: 1,
	PI: 0.5
}
const DIRECTION_CHANGE_CHANCE: float = 0.5
const NEW_WALKER_CHANCE: float = 0.2
const DESTROY_WALKER_CHANCE: float = 0.2
const MIN_ROOMS: int = 6
const MAX_ROOMS: int = 8
const ROOM_WEIGHTS := {
	preload("res://src/world/resources/data/room_1.tres"): 1,
	preload("res://src/world/resources/data/room_2.tres"): 1
}


## Grilla con las distintas habitaciones.
var grid: Dictionary[Vector2i, RoomData] = {}


## Se mueve en direcciones aleatorias para generar la
## grilla.
class Walker:
	var dir: Vector2i 
	var pos: Vector2i 



func _ready() -> void:
	generate_grid()
	
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_accept"):
		generate_grid()
	
	
func generate_grid() -> void:
	grid.clear()
	var starting_position: Vector2i = Vector2i.ZERO

	var walkers: Array[Walker]
	var walked_cells: Array[Vector2i]

	var iterations: int = 0

	_add_walker(starting_position, walkers)

	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	var amount: int = randi_range(MIN_ROOMS, MAX_ROOMS)

	while iterations < 10000 and walked_cells.size() < amount:
		for walker in walkers:
			if not walked_cells.has(walker.pos):
				walked_cells.append(walker.pos)
			if rng.randf() <= DESTROY_WALKER_CHANCE and walkers.size() > 1:
				walkers.erase(walker)
				continue

			if rng.randf() <= NEW_WALKER_CHANCE:
				_add_walker(walker.pos, walkers)

			if rng.randf() <= DIRECTION_CHANGE_CHANCE:
				var direction: int = rng.rand_weighted(ROTATION_WEIGHTS.values())
				walker.dir = Vector2i(Vector2(walker.dir).rotated(
					ROTATION_WEIGHTS.keys()[direction]
				))
				print(walker.dir)

			walker.pos += walker.dir


			if walked_cells.size() >= amount:
				break

		iterations += 1
	
	for cell in walked_cells:
		grid.set(cell, ROOM_WEIGHTS.keys()[rng.rand_weighted(ROOM_WEIGHTS.values())])
	layout_generated.emit(grid)
	

func _add_walker(pos: Vector2i, array: Array[Walker]) -> void:
	var walker: Walker = Walker.new()
	walker.pos = pos
	walker.dir = (
		[
			Vector2.LEFT,
			Vector2.RIGHT,
			Vector2.DOWN,
			Vector2.UP
		].pick_random()
	)
	array.append(walker)
