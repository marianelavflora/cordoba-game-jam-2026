extends Node3D

const WALL_TEXTURE_WAINSCOTING := "res://Texturas/wall_wainscoting.png"
const WALL_TEXTURE_WHITE := "res://Texturas/wall_mall.png"
const WALL_TEXTURE_BRICK := "res://Texturas/wall_brick.png"
const MIN_ENEMIES := 1
const MAX_ENEMIES := 3
const ENEMY_1 = preload("uid://nuwtpmjln7tl")

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
@onready var enemies_pos: Node3D = $EnemiesPos

var cell: Vector2i = Vector2i.ZERO


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


func _spawn_enemies() -> void:
	var amount: int = randi_range(MIN_ENEMIES, MAX_ENEMIES)
	var positions := enemies_pos.get_children()
	positions.shuffle()
	positions.resize(amount)
	for pos in positions:
		var enemy: CharacterBody3D = ENEMY_1.instantiate()
		enemy.position = pos.position
		add_child(enemy)


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player and cell != Vector2i.ZERO:
		_spawn_enemies()
