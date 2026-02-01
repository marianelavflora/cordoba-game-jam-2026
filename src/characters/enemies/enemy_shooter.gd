extends CharacterBody3D

@export var patrol_radius: float = 3.0
@export var patrol_angular_speed: float = 1.2 # rad/s
@export var fire_interval: float = 0.8
@export var fire_range: float = 18.0
@export var bullet_speed: float = 10.0

@onready var muzzle: Node3D = $Muzzle

const BULLET_SCENE: PackedScene = preload("res://src/characters/enemies/enemy_bullet.tscn")

var _center: Vector3
var _angle: float = 0.0
var _fire_cd: float = 0.0

func _ready() -> void:
	_center = global_position
	_fire_cd = randf_range(0.1, fire_interval)

func _physics_process(delta: float) -> void:
	# 1) Patrulla en círculo (independiente de colliders)
	_angle += patrol_angular_speed * delta
	var offset := Vector3(cos(_angle), 0.0, sin(_angle)) * patrol_radius
	global_position = _center + offset

	# 2) Buscar player (solo actuar si está en la misma habitación)
	var player := get_tree().get_first_node_in_group("player") as Node3D
	if player == null:
		return
	if RoomPlacer.get_room_cell(player.global_position) != RoomPlacer.get_room_cell(global_position):
		return

	# 3) Apuntar y disparar
	var to_player: Vector3 = player.global_position - global_position
	to_player.y = 0.0
	var dist := to_player.length()
	if dist <= 0.01:
		return

	_fire_cd = maxf(_fire_cd - delta, 0.0)
	if dist <= fire_range and _fire_cd <= 0.0:
		_shoot(to_player.normalized())
		_fire_cd = fire_interval

func _shoot(dir: Vector3) -> void:
	var bullet: Area3D = BULLET_SCENE.instantiate() as Area3D
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = muzzle.global_position
	bullet.direction = dir
	bullet.speed = bullet_speed
	
	
