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
	spawn_windows()

func spawn_windows() -> void:
	for i in range(randi_range(level, level + 2)):
		var b: Control = window_scene.instantiate()
		b.visible = false
		b.won_window.connect(close_window)
		windows.append(b)
	windows_spawned = true
	make_windows_appear()

func make_windows_appear() -> void:
	made_windows_appear = true
	var current_window: int = 0
	windows_made_appear = [false]
	windows_closed = [false]
	while windows_made_appear.size() < windows.size():
		windows_made_appear.append(false)
		windows_closed.append(false)
	for i in windows:
		i.visible = true
		i.current_state = true
		add_child(i)
		if not i.is_node_ready():
			print("HAVE TO WAIT FOR READY")
			await i.ready
		windows_made_appear[current_window] = true
		current_window += 1
		# await get_tree().physics_frame
	for i in get_tree().get_nodes_in_group("fail_button"):
		i.pressed.connect(pressed_lose_button)

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
		made_windows_appear = true
		make_windows_appear()
