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

var past_splash: bool = false
var entered_settings: bool = false

var highest_time: float
var highest_microgames_won: int
var current_time: float
var current_microgames_won: int

var beat_game: bool = false
var beat_pb: bool = false
var times_played: int = 0

var fixing_audio: bool = false
var tween: Tween

var music_transition_time: float = 2

var default_volume_levels: Dictionary = {
	"Master": linear_to_db(1.0),
	"Music": linear_to_db(1.0),
	"Sound Effects": linear_to_db(1.0),
	"Microgame Sound Effects": linear_to_db(1.0),
}

var music_level: MUSIC_LEVEL = MUSIC_LEVEL.OFF:
	set(value):
		music_level = value
		update_level(value)

func _ready() -> void:
	get_tree().set_auto_accept_quit(false)
	load_game()
	music_player = AudioStreamPlayer.new()
	music_player.stream = music_resource
	music_player.bus = "Music"
	music_player.volume_db = -20
	music_player.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(music_player)
	# music_player.play()

func load_game() -> void:
	load_settings()

func load_settings() -> void:
	if not FileAccess.file_exists("user://settings.save"):
		print("No settings file, loading default settings")
		load_default_settings()
	else:
		var save_file = FileAccess.open("user://settings.save", FileAccess.READ)
		var json_string: String = save_file.get_line()
		var json: JSON = JSON.new()
		var parse_result: Error = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			print("Loading default settings as backup")
			load_default_settings()
			return
		var data: Dictionary = json.data
		for i in data.keys():
			if default_volume_levels.has(i):
				print("Volume data, setting volume of bus")
				set_volume(i, data[i])

func load_default_settings() -> void:
	print("Loading default volume levels")
	for i in default_volume_levels.keys():
		set_volume(i, default_volume_levels[i])

func get_volume(bus: String) -> float:
	return AudioServer.get_bus_volume_db(AudioServer.get_bus_index(bus))

func set_volume(bus: String, volume: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus), volume)

func save_game() -> void:
	if entered_settings:
		save_settings()
	print("GAME SAVED")

func save_settings() -> void:
	var save_file: FileAccess = FileAccess.open("user://settings.save", FileAccess.WRITE)
	var save_dict: Dictionary = save_settings_dict()
	var json_string: String = JSON.stringify(save_dict)
	save_file.store_line(json_string)

func save_settings_dict() -> Dictionary:
	var volumedict: Dictionary = default_volume_levels
	for i in volumedict.keys():
		volumedict[i] = get_volume(i)
	var savedict: Dictionary = {}
	savedict.merge(volumedict)
	return savedict

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if past_splash:
			save_game()
		get_tree().quit()

func update_time(value, value2) -> void:
	if not beat_game:
		beat_game = true
	times_played += 1
	current_time = value
	current_microgames_won = value2
	if floor(value) > floor(highest_time):
		highest_time = value
		highest_microgames_won = value2
		beat_pb = true
	elif floor(value) == floor(highest_time) and value2 > highest_microgames_won:
		highest_time = value
		highest_microgames_won = value2
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
