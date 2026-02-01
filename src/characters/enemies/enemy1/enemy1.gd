extends CharacterBody3D
# ---- AUDIO ----
@export var step_stream: AudioStream
@export var hurt_stream: AudioStream
@export var death_stream: AudioStream

var step_audio: AudioStreamPlayer3D
var hurt_audio: AudioStreamPlayer3D
var death_audio: AudioStreamPlayer3D

var step_timer := 0.0
@export var step_interval_walk := 0.6
@export var step_interval_run := 0.35

@export var walk_speed: float = 2.0
@export var run_speed: float = 4.5
@export var state_time: float = 3.0
@export var max_health: int = 7

# ---- DAÑO POR CONTACTO ----
@export var contact_damage: int = 1
@export var damage_interval: float = 0.8
var damage_cooldown: float = 0.0

var health: int
var player: Node3D

var is_running: bool = false
var state_timer: float = 0.0

@onready var mesh_alive: MeshInstance3D = $MeshAlive
@onready var mesh_dead: MeshInstance3D = $MeshDead
@onready var collision: CollisionShape3D = $CollisionShape3D

func _ready():
	health = max_health
	mesh_dead.visible = false
	player = get_tree().get_first_node_in_group("player")

	step_audio = AudioStreamPlayer3D.new()
	step_audio.stream = step_stream
	step_audio.bus = "SFX"
	step_audio.unit_size = 6.0
	step_audio.autoplay = false
	add_child(step_audio)

	hurt_audio = AudioStreamPlayer3D.new()
	hurt_audio.stream = hurt_stream
	hurt_audio.bus = "SFX"
	hurt_audio.unit_size = 6.0
	add_child(hurt_audio)

	death_audio = AudioStreamPlayer3D.new()
	death_audio.stream = death_stream
	death_audio.bus = "SFX"
	death_audio.unit_size = 8.0
	add_child(death_audio)

func _physics_process(delta: float) -> void:
	if health <= 0 or player == null:
		return

	# Solo perseguir si el jugador está en la misma habitación
	if RoomPlacer.get_room_cell(player.global_position) != RoomPlacer.get_room_cell(global_position):
		velocity = Vector3.ZERO
		move_and_slide()
		return

	# cooldown del daño
	damage_cooldown = maxf(damage_cooldown - delta, 0.0)

	# CAMBIO DE ESTADO CADA X SEGUNDOS
	state_timer += delta
	if state_timer >= state_time:
		state_timer = 0.0
		is_running = !is_running

	var speed = run_speed if is_running else walk_speed

	# DIRECCIÓN AL JUGADOR (SIN ROTAR)
	var direction = player.global_position - global_position
	direction.y = 0
	direction = direction.normalized()

	# MOVIMIENTO
	velocity = direction * speed
	move_and_slide()


	# ---- DAÑO POR CONTACTO ----
	if damage_cooldown <= 0.0:
		for i in range(get_slide_collision_count()):
			var collision_info := get_slide_collision(i)
			var body := collision_info.get_collider()
			if body != null and body.is_in_group("player"):
				body.take_damage(contact_damage)
				damage_cooldown = damage_interval
				break
	if velocity.length() > 0.1 and step_stream:
		step_timer -= delta
	if step_timer <= 0.0:
		step_audio.play()
		step_timer = step_interval_run if is_running else step_interval_walk
func take_damage(amount: int) -> void:
	if health <= 0:
		return
	if hurt_stream:
		hurt_audio.play()
	health -= amount
	if health <= 0:
		die()

func die() -> void:
	mesh_alive.visible = false
	mesh_dead.visible = true
	collision.disabled = true
	if death_stream:
		death_audio.play()
	await get_tree().create_timer(2.0).timeout
	queue_free()
