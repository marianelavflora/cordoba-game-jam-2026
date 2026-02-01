extends Node3D

const FADE_IN_DURATION: float = 1.5

var fade_timer: float = 0.0
var is_fading_in: bool = true
var target_volume: float = -5.0

@onready var music_player: AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	if music_player:
		# Iniciar con volumen muy bajo
		music_player.volume_db = -80.0
		music_player.play()

func _process(delta: float) -> void:
	if is_fading_in and music_player:
		fade_timer += delta
		var fade_progress: float = fade_timer / FADE_IN_DURATION
		music_player.volume_db = lerp(-80.0, target_volume, fade_progress)
		
		if fade_timer >= FADE_IN_DURATION:
			is_fading_in = false
			music_player.volume_db = target_volume
