extends CanvasLayer

const IMAGE_DURATION: float = 2.2
const FADE_DURATION: float = 1.5
const INTRO_IMAGES: Array[String] = [
	"res://INTRO/intro1.png",
	"res://INTRO/intro2.png",
	"res://INTRO/intro3.png",
	"res://INTRO/intro4.png",
	"res://INTRO/intro5.png",
	"res://INTRO/intro6.png",
	"res://INTRO/intro7.png"
]

var current_index: int = 0
var time_accumulated: float = 0.0
var is_fading: bool = false
var fade_timer: float = 0.0
var initial_volume: float = -5.0

@onready var texture_rect: TextureRect = $TextureRect
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	# Cargar primera imagen
	_load_image(0)
	
	# Reproducir música
	initial_volume = audio_player.volume_db
	audio_player.play()

func _process(delta: float) -> void:
	if is_fading:
		# Fade out de la música
		fade_timer += delta
		var fade_progress: float = fade_timer / FADE_DURATION
		audio_player.volume_db = lerp(initial_volume, -80.0, fade_progress)
		return
	
	time_accumulated += delta
	
	# Cambiar imagen cada IMAGE_DURATION segundos
	if time_accumulated >= IMAGE_DURATION:
		time_accumulated = 0.0
		current_index += 1
		
		if current_index >= INTRO_IMAGES.size():
			# Intro terminada, comenzar fade
			_start_fade()
		else:
			_load_image(current_index)

func _load_image(index: int) -> void:
	if index < 0 or index >= INTRO_IMAGES.size():
		return
	
	var texture: Texture2D = load(INTRO_IMAGES[index]) as Texture2D
	if texture:
		texture_rect.texture = texture

func _start_fade() -> void:
	is_fading = true
	fade_timer = 0.0
	
	# Cambiar escena inmediatamente para que las músicas se sobrepongan
	get_tree().change_scene_to_file("res://src/scenes/main/main.tscn")

func _finish_intro() -> void:
	# Ir a la escena principal del juego inmediatamente
	get_tree().change_scene_to_file("res://src/scenes/main/main.tscn")

func _input(event: InputEvent) -> void:
	# Permitir saltar la intro presionando SPACE o ENTER
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_select"):
		_finish_intro()
