extends Node3D

## Este script bloquea una puerta con un shopping cart hasta que todos los enemigos 
## dentro del área cuadrada de la habitación sean eliminados

const SHOPPING_CART_SCALE := 0.012  # Doble del tamaño anterior (0.006 * 2)
const CHECK_INTERVAL := 0.5  # Revisar enemigos cada 0.5 segundos

var blocker_mesh: MeshInstance3D
var blocker_body: StaticBody3D
var check_timer: float = 0.0
var is_blocked: bool = true
var room_bounds: Rect2  # Área cuadrada de la habitación

func _ready() -> void:
	_calculate_room_bounds()
	_create_blocker()
	
func _process(delta: float) -> void:
	if not is_blocked:
		return
	
	check_timer -= delta
	if check_timer <= 0.0:
		check_timer = CHECK_INTERVAL
		_check_enemies()

func _calculate_room_bounds() -> void:
	# Obtener el tamaño de la habitación desde RoomPlacer
	var room_size := RoomPlacer.get_room_size_2d()
	
	# Obtener la celda de la habitación donde está este blocker
	var room_cell := RoomPlacer.get_room_cell(global_position)
	
	# Calcular el centro mundial de la habitación
	var room_center_x: float = room_cell.x * room_size.x
	var room_center_z: float = room_cell.y * room_size.y
	
	# Crear el rectángulo un poco MÁS PEQUEÑO que la habitación para evitar detectar enemigos vecinos
	# Reducir 20% el área (factor 0.8)
	var reduced_size := room_size * 0.8
	var half_size := reduced_size / 2.0
	
	room_bounds = Rect2(
		Vector2(room_center_x - half_size.x, room_center_z - half_size.y),
		reduced_size
	)
	
	print("DoorBlocker: Room cell=", room_cell, " center=(", room_center_x, ",", room_center_z, ") bounds=", room_bounds)

func _create_blocker() -> void:
	# Cargar el mesh del shopping cart
	var mesh: Mesh = load("res://assets/objs/ShoppingCart.obj") as Mesh
	if mesh == null:
		push_error("DoorBlocker: No se pudo cargar ShoppingCart.obj")
		return
	
	# Crear MeshInstance3D
	blocker_mesh = MeshInstance3D.new()
	blocker_mesh.mesh = mesh
	blocker_mesh.scale = Vector3(SHOPPING_CART_SCALE, SHOPPING_CART_SCALE, SHOPPING_CART_SCALE)
	
	# Rotar para que esté vertical y mirando hacia adelante
	blocker_mesh.rotation_degrees = Vector3(-90, 0, 0)
	
	# NO mover hacia adelante - quedarse en el centro del doorhole
	# blocker_mesh.position está en (0, 0, 0) relativo al nodo padre
	
	# Crear material gris metálico
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.6, 0.6, 0.65, 1.0)
	mat.metallic = 0.7
	mat.roughness = 0.3
	blocker_mesh.material_override = mat
	
	# Crear StaticBody3D con collider
	blocker_body = StaticBody3D.new()
	# NO offset - collider también en el centro
	
	var collision_shape := CollisionShape3D.new()
	var box_shape := BoxShape3D.new()
	
	# Tamaño del collider para bloquear la puerta (más ancho, menos profundo)
	box_shape.size = Vector3(0.9, 1.3, 0.5)
	collision_shape.shape = box_shape
	collision_shape.position = Vector3(0, 0.65, 0)  # Centrar verticalmente
	
	blocker_body.add_child(collision_shape)
	
	# Agregar ambos a la escena
	add_child(blocker_mesh)
	add_child(blocker_body)

func _check_enemies() -> void:
	# Buscar todos los enemigos en el grupo "enemies"
	var all_enemies := get_tree().get_nodes_in_group("enemies")
	
	print("DoorBlocker: Checking enemies, total in game: ", all_enemies.size())
	
	# Revisar si hay algún enemigo dentro del área cuadrada de la habitación
	var has_enemies := false
	var enemies_in_room := 0
	for enemy in all_enemies:
		if enemy is Node3D:
			var enemy_pos: Vector3 = enemy.global_position
			var enemy_pos_2d := Vector2(enemy_pos.x, enemy_pos.z)
			
			# Verificar si el enemigo está dentro del rectángulo de la habitación
			if room_bounds.has_point(enemy_pos_2d):
				has_enemies = true
				enemies_in_room += 1
	
	print("DoorBlocker: Enemies in room area: ", enemies_in_room)
	
	# Si no hay enemigos en la habitación, remover el blocker
	if not has_enemies:
		print("DoorBlocker: No enemies detected, removing blocker!")
		_remove_blocker()

func _remove_blocker() -> void:
	if not is_blocked:
		return
	
	is_blocked = false
	
	# Animación de desaparición (tween)
	var tween := create_tween()
	tween.set_parallel(true)
	
	if blocker_mesh:
		tween.tween_property(blocker_mesh, "scale", Vector3.ZERO, 0.5)
		tween.tween_property(blocker_mesh, "position:y", 2.0, 0.5)
	
	if blocker_body:
		# Desactivar collider inmediatamente
		for child in blocker_body.get_children():
			if child is CollisionShape3D:
				child.disabled = true
	
	# Eliminar después de la animación
	tween.tween_callback(queue_free).set_delay(0.5)
