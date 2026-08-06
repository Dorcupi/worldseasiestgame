extends Microgame

@export var window_scene: PackedScene

var windows_spawned: bool = false
var made_windows_appear: bool = false
var windows_made_appear: Array = []
var windows_closed: Array = []
var windows: Array = []

@onready var time_label: Label = $CanvasLayer/ColorRect/MarginContainer/HBoxContainer2/TimeLabel

@onready var time_dict = Time.get_time_dict_from_system()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if str(time_dict.hour).length() <= 1:
		time_label.text = "0" + str(time_dict.hour) + ":"
	else:
		time_label.text = str(time_dict.hour) + ":"
	if str(time_dict.minute).length() <= 1: time_label.text += "0"
	time_label.text += str(time_dict.minute)
	print("UPDATED TIME, SPAWNING WINDOWS")
	spawn_windows()

func spawn_windows() -> void:
	for i in range(randi_range(level, level + 2)):
		print("WINDOW NUMBER %.0f" % i)
		var b: Control = window_scene.instantiate()
		print("INSTANTIATED")
		b.visible = false
		print("MADE INVISIBLE")
		b.won_window.connect(close_window)
		print("CONNECTED SIGNALS")
		windows.append(b)
		print("APPENDED")
	print("ALL DONE, CHANGING VARIABLE AND MAKING WINDOWS APPEAR")
	windows_spawned = true
	make_windows_appear()

func make_windows_appear() -> void:
	made_windows_appear = true
	var current_window: int = 0
	print("SET VARIABLES")
	windows_made_appear = [false]
	windows_closed = [false]
	print("STARTING ARRAY POPULATION, WINDOWS ARRAY SIZE IS %.0f" % windows.size())
	while windows_made_appear.size() < windows.size():
		print("WINDOWS MADE APPEAR SIZE IS %.0f" % windows_made_appear.size())
		windows_made_appear.append(false)
		windows_closed.append(false)
		print("APPENDED")
	print("DONE MAKING WINDOWS VISIBLE")
	for i in windows:
		i.visible = true
		print("MADE VISIBLE")
		i.current_state = true
		print("SET CURRENT STATE TO TRUE")
		add_child(i)
		print("ADDED CHILD")
		if not i.is_node_ready():
			print("HAVE TO WAIT FOR READY")
			await i.ready
		windows_made_appear[current_window] = true
		current_window += 1
		print("UPDATED ARRAY AND ADDED ONE TO CURRENT WINDOW")
		# await get_tree().physics_frame
	print("DONE, ADDING FAIL BUTTON SIGNALS")
	for i in get_tree().get_nodes_in_group("fail_button"):
		i.pressed.connect(pressed_lose_button)
	print("DONE")

func close_window(window: Control) -> void:
	windows_closed[windows.find(window)] = true
	var succeed: bool = true
	for i in windows_closed:
		if i == false:
			succeed = false
	if succeed:
		win_game.emit()

func pressed_lose_button() -> void:
	for i in windows:
		remove_child(i)
		i.current_state = false
	lose_game.emit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if game_playing and not made_windows_appear and windows_spawned:
		print("HAVEN'T MADE WINDOWS APPEAR, MAKING WINDOWS APPEAR")
		made_windows_appear = true
		make_windows_appear()
