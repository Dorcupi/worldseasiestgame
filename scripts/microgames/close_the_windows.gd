extends Microgame

@export var window_scene: PackedScene

var windows_spawned: bool = false
var made_windows_appear: bool = false
var windows_made_appear: Array = []
var windows_closed: Array = []

@onready var time_label: Label = $CanvasLayer/ColorRect/MarginContainer/HBoxContainer2/TimeLabel

@onready var time_dict = Time.get_time_dict_from_system()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	time_label.text = str(time_dict.hour) + ":" + str(time_dict.minute)
	spawn_windows()

func spawn_windows() -> void:
	for i in range(randi_range(level, level + 2)):
		var b: Control = window_scene.instantiate()
		b.visible = false
		b.won_window.connect(close_window)
		add_child(b)
		if not b.is_node_ready():
			print("HAVE TO WAIT FOR READY")
			await b.ready
	for i in get_tree().get_nodes_in_group("fail_button"):
		i.pressed.connect(pressed_lose_button)
	windows_spawned = true

func make_windows_appear() -> void:
	made_windows_appear = true
	var current_window: int = 0
	windows_made_appear = [false]
	windows_closed = [false]
	while windows_made_appear.size() < get_tree().get_nodes_in_group("window").size():
		windows_made_appear.append(false)
		windows_closed.append(false)
	for i in get_tree().get_nodes_in_group("window"):
		i.visible = true
		i.current_state = true
		windows_made_appear[current_window] = true
		current_window += 1
		await get_tree().physics_frame

func close_window(window: Control) -> void:
	windows_closed[get_tree().get_nodes_in_group("window").find(window)] = true
	var succeed: bool = true
	for i in windows_closed:
		if i == false:
			succeed = false
	if succeed:
		win_game.emit()

func pressed_lose_button() -> void:
	for i in get_tree().get_nodes_in_group("window"):
		i.hide()
		i.current_state = false
	lose_game.emit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if game_playing and not made_windows_appear and windows_spawned:
		make_windows_appear()
