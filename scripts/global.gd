extends Node

enum MUSIC_LEVEL {
	OFF,
	LEVEL_1,
	LEVEL_2,
	LEVEL_3,
	LEVEL_4,
	LEVEL_5,
	LEVEL_6
}

const LEVEL_PRESETS: Dictionary[MUSIC_LEVEL, Array] = {
	MUSIC_LEVEL.OFF: [-60.0, -60.0, -60.0, -60.0, -60.0, -60.0],
	MUSIC_LEVEL.LEVEL_1: [0.0, -60.0, -60.0, -60.0, -60.0, -60.0],
	MUSIC_LEVEL.LEVEL_2: [0.0, 0.0, -60.0, -60.0, -60.0, -60.0],
	MUSIC_LEVEL.LEVEL_3: [0.0, 0.0, 0.0, -60.0, -60.0, -60.0],
	MUSIC_LEVEL.LEVEL_4: [0.0, 0.0, 0.0, 0.0, -60.0, -60.0],
	MUSIC_LEVEL.LEVEL_5: [0.0, 0.0, 0.0, 0.0, 0.0, -60.0],
	MUSIC_LEVEL.LEVEL_6: [0.0, 0.0, 0.0, 0.0, 0.0, 3.0],
}

var music_player: AudioStreamPlayer
@onready var music_resource: AudioStreamSynchronized = preload("res://resources/music.tres")

var highest_time: float
var current_time: float

var beat_game: bool = false
var beat_pb: bool = false
var times_played: int = 0

var fixing_audio: bool = false
var tween: Tween

var music_transition_time: float = 2

var music_level: MUSIC_LEVEL = MUSIC_LEVEL.OFF:
	set(value):
		music_level = value
		update_level(value)

func _ready() -> void:
	music_player = AudioStreamPlayer.new()
	music_player.stream = music_resource
	music_player.bus = "Music"
	music_player.volume_db = -20
	music_player.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(music_player)
	# music_player.play()

func update_time(value) -> void:
	if not beat_game:
		beat_game = true
	times_played += 1
	current_time = value
	if value > highest_time:
		highest_time = value
		beat_pb = true
	else:
		beat_pb = false

func update_level(level: MUSIC_LEVEL) -> void:
	var created_tween: bool = false
	for i in range(music_player.stream.get_stream_count()):
		if music_player.stream.get_sync_stream_volume(i) != LEVEL_PRESETS[level][i]:
			if not created_tween:
				fixing_audio = true
				created_tween = true
				if tween: tween.kill()
				tween = create_tween()
				tween.tween_method(update_stream_volume.bind(i), music_player.stream.get_sync_stream_volume(i), LEVEL_PRESETS[level][i], music_transition_time).set_trans(Tween.TRANS_EXPO)
			else:
				tween.parallel().tween_method(update_stream_volume.bind(i), music_player.stream.get_sync_stream_volume(i), LEVEL_PRESETS[level][i], music_transition_time).set_trans(Tween.TRANS_EXPO)
	if created_tween:
		tween.tween_callback(func ():
			tween.kill()
			fixing_audio = false)

func check_level_correct(level: MUSIC_LEVEL) -> void:
	var created_tween: bool = false
	for i in range(music_player.stream.get_stream_count()):
		if music_player.stream.get_sync_stream_volume(i) != LEVEL_PRESETS[level][i]:
			if not created_tween:
				fixing_audio = true
				if tween: tween.kill()
				tween = create_tween()
				tween.tween_method(update_stream_volume.bind(i), music_player.stream.get_sync_stream_volume(i), LEVEL_PRESETS[level][i], music_transition_time).set_trans(Tween.TRANS_EXPO)
			else:
				tween.parallel().tween_method(update_stream_volume.bind(i), music_player.stream.get_sync_stream_volume(i), LEVEL_PRESETS[level][i], music_transition_time).set_trans(Tween.TRANS_EXPO)
	if created_tween:
		tween.tween_callback(func ():
			tween.kill()
			fixing_audio = false)

func update_stream_volume(volume: float, stream: int) -> void:
	music_player.stream.set_sync_stream_volume(stream, volume)

func _physics_process(delta: float) -> void:
	if music_level != MUSIC_LEVEL.OFF and not music_player.is_playing():
		music_player.play()
	if music_level == MUSIC_LEVEL.OFF and music_player.is_playing() and not fixing_audio:
		music_player.stop()
