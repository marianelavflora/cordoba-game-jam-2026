extends Node

@export var enemy_scene: PackedScene = preload("res://src/characters/enemies/enemy_shooter.tscn")
@export var spawn_offset: Vector3 = Vector3(3, 0, 2)

func _ready() -> void:
	call_deferred("_spawn_once")

func _spawn_once() -> void:
	var players := get_tree().get_nodes_in_group("player")
	if players.is_empty():
		push_warning("EnemySpawner: no encontré ningún nodo en el grupo 'player'.")
		return

	var player := players[0] as Node3D
	if player == null:
		push_warning("EnemySpawner: el nodo del grupo 'player' no es Node3D.")
		return

	if enemy_scene == null:
		push_warning("EnemySpawner: enemy_scene es null.")
		return

	var enemy := enemy_scene.instantiate() as Node3D
	get_tree().current_scene.add_child(enemy)

	enemy.global_position = player.global_position + spawn_offset
