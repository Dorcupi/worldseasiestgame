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

enum AFTER_CUTSCENE_ACTION {
	CONTINUE,
	SWITCH_SCENE,
	QUIT
}

const CUTSCENES: Dictionary[String, DialogicTimeline] = {
	"intro": preload("res://timelines/intro.dtl"),
	"after_game_1": preload("res://timelines/game1.dtl")
}

const CUTSCENES_AFTER: Dictionary[String, AFTER_CUTSCENE_ACTION] = {
	"intro": AFTER_CUTSCENE_ACTION.SWITCH_SCENE,
	"after_game_1": AFTER_CUTSCENE_ACTION.CONTINUE
}

const CUTSCENE_SWITCH: Dictionary[String, PackedScene] = {
	"intro": preload("res://scenes/main.tscn")
}

const AFTER_GAME_CUTSCENE: Dictionary[int, String] = {
	1: "after_game_1"
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

const MOUSE_ICONS: Dictionary[Input.CursorShape, Texture] = {
	Input.CursorShape.CURSOR_ARROW: preload("res://assets/cursor/cursor_none.svg"),
	Input.CursorShape.CURSOR_IBEAM: preload("res://assets/cursor/bracket_b_vertical.svg"),
	Input.CursorShape.CURSOR_POINTING_HAND: preload("res://assets/cursor/hand_small_point.svg"),
	Input.CursorShape.CURSOR_CROSS: preload("res://assets/cursor/line_cross.svg"),
	Input.CursorShape.CURSOR_WAIT: preload("res://assets/cursor/busy_hourglass_outline_detail.svg"),
	Input.CursorShape.CURSOR_BUSY: preload("res://assets/cursor/cursor_busy.svg"),
	Input.CursorShape.CURSOR_DRAG: preload("res://assets/cursor/hand_closed.svg"),
	# insert cursor can drop here
	Input.CursorShape.CURSOR_FORBIDDEN: preload("res://assets/cursor/cursor_disabled.svg"),
	Input.CursorShape.CURSOR_VSIZE: preload("res://assets/cursor/resize_a_vertical.svg"),
	Input.CursorShape.CURSOR_HSIZE: preload("res://assets/cursor/resize_a_horizontal.svg"),
	Input.CursorShape.CURSOR_BDIAGSIZE: preload("res://assets/cursor/resize_a_diagonal.svg"),
	Input.CursorShape.CURSOR_FDIAGSIZE: preload("res://assets/cursor/resize_a_diagonal_mirror.svg"),
	Input.CursorShape.CURSOR_MOVE: preload("res://assets/cursor/resize_a_cross.svg"),
	Input.CursorShape.CURSOR_VSPLIT: preload("res://assets/cursor/resize_b_vertical.svg"),
	Input.CursorShape.CURSOR_HSPLIT: preload("res://assets/cursor/resize_b_horizontal.svg"),
	Input.CursorShape.CURSOR_HELP: preload("res://assets/cursor/cursor_help.svg")
}

signal switched_to_keyboard
signal switched_from_keyboard

var music_player: AudioStreamPlayer
@onready var music_resource: AudioStreamSynchronized = preload("res://resources/music.tres")

var past_splash: bool = false
var entered_settings: bool = false
var using_controller: bool = false

var highest_time: float
var highest_microgames_won: int
var current_time: float
var current_microgames_won: int

var beat_game: bool = false
var beat_pb: bool = false
var times_played: int = 0

var after_cutscene_ready: bool = false
var after_cutscene: String

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
	update_cursor()
	load_game()
	music_player = AudioStreamPlayer.new()
	music_player.stream = music_resource
	music_player.bus = "Music"
	music_player.volume_db = -20
	music_player.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(music_player)
	# music_player.play()

func _input(event: InputEvent) -> void:
	if event is InputEventKey or event is InputEventMouseButton or event is InputEventMouseMotion:
		if using_controller:
			print("KEYBOARD ACTIVE")
			using_controller = false
			switched_to_keyboard.emit()
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		if event is InputEventJoypadMotion and abs(event.axis_value) > 0.2:
			pass
		elif event is InputEventJoypadMotion:
			return
		if !using_controller:
			print("CONTROLLER ACTIVE")
			using_controller = true
			switched_from_keyboard.emit()

func update_cursor() -> void:
	for i in MOUSE_ICONS.keys():
		Input.set_custom_mouse_cursor(MOUSE_ICONS[i], i)

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
	if AFTER_GAME_CUTSCENE.has(times_played):
		after_cutscene_ready = true
		after_cutscene = AFTER_GAME_CUTSCENE[times_played]
	else:
		after_cutscene_ready = false

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
