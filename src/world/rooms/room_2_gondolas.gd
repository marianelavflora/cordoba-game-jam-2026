extends Node3D

const GONDOLA_POSITIONS := [
	Vector3(-2.9884124, 0.0, 1.8641739),
	Vector3(3.523512, 0.0, -2.0329194)
]
const WALL_HEIGHT := 1.825
const MAX_GONDOLA_HEIGHT := 1.4  # No superar altura de paredes

func _ready() -> void:
	var mesh: Mesh = load("res://assets/objs/Gondola001.obj") as Mesh
	if mesh == null:
		push_error("No se pudo cargar Gondola001.obj")
		return
	
	# Calcular escala necesaria basada en el AABB del mesh
	var aabb := mesh.get_aabb()
	var mesh_height := aabb.size.y
	var scale_factor := MAX_GONDOLA_HEIGHT / mesh_height if mesh_height > 0 else 1.0
	
	for pos in GONDOLA_POSITIONS:
		# Contenedor principal para la góndola
		var container := Node3D.new()
		container.position = pos
		
		# Mesh instance
		var mi := MeshInstance3D.new()
		mi.mesh = mesh
		mi.scale = Vector3(scale_factor, scale_factor, scale_factor)
		
		# StaticBody3D para colisión (mismo nivel que el mesh)
		var static_body := StaticBody3D.new()
		static_body.scale = Vector3(scale_factor, scale_factor, scale_factor)
		
		var collision_shape := CollisionShape3D.new()
		var box_shape := BoxShape3D.new()
		box_shape.size = aabb.size
		collision_shape.shape = box_shape
		collision_shape.position = aabb.get_center()
		
		static_body.add_child(collision_shape)
		
		# Agregar ambos al contenedor
		container.add_child(mi)
		container.add_child(static_body)
		
		add_child(container)
