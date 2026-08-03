extends Microgame

@export var window_scene: PackedScene

var made_windows_appear: bool = false
var windows_made_appear: Array = []
var windows_closed: Array = []

@onready var time_label: Label = $CanvasLayer/ColorRect/MarginContainer/HBoxContainer2/TimeLabel

@onready var time_dict = Time.get_time_dict_from_system()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(randi_range(level, level + 2)):
		var b: Window = window_scene.instantiate()
		b.visible = false
		b.won_window.connect(close_window)
		add_child(b)
	for i in get_tree().get_nodes_in_group("fail_button"):
		i.pressed.connect(pressed_lose_button)
	time_label.text = str(time_dict.hour) + ":" + str(time_dict.minute)

func make_windows_appear() -> void:
	var current_window: int = 0
	windows_made_appear = [false]
	windows_closed = [false]
	while windows_made_appear.size() < get_tree().get_nodes_in_group("window").size():
		windows_made_appear.append(false)
		windows_closed.append(false)
	for i in get_tree().get_nodes_in_group("window"):
		i.show()
		i.current_state = true
		windows_made_appear[current_window] = true
		current_window += 1
		await get_tree().physics_frame
	made_windows_appear = true

func close_window(window: Window) -> void:
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
	if game_playing and not made_windows_appear:
		make_windows_appear()
