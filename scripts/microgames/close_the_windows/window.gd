extends Control
signal won_window(window: Control)
var current_state: bool = false

var title: String:
	set(value):
		title = value
		if title_label:
			title_label.text = value

var mouse_in_titlebar: bool = false
var mouse_held: bool = false
var titlebar_grabbed: bool = false

var current_mouse: Vector2

@onready var window_content: MarginContainer = $MarginContainer2/Control/WindowContent
@onready var title_bar: ColorRect = $MarginContainer2/Control/TitleBar
@onready var title_label: Label = $MarginContainer2/Control/TitleBar/TitleLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("RUNNING SPAWN FUNCTION")
	spawn()
	print("DONE RUNNING SPAWN FUNCTION, ADDING SIGNALS")
	title_bar.mouse_entered.connect(titlebar_mouse.bind(true))
	title_bar.mouse_exited.connect(titlebar_mouse.bind(false))
	title_bar.gui_input.connect(titlebar_input)
	print("DONE ADDING SIGNALS, DONE DONE")

func spawn() -> void: # might be where the crashes are coming from
	print("UPDATING X SIZE")
	size.x = randi_range(300, 700)
	print("DONE, UPDATING Y SIZE")
	size.y = randi_range(300, 700)
	print("DONE, UPDATING X POSITION")
	global_position.x = randf_range(0 - int(size.x / 2), get_viewport_rect().size.x - int(size.x / 2))
	print("DONE, UPDATING Y POSITION")
	global_position.y = randf_range(63, get_viewport_rect().size.y - 83)
	print("DONE, CHOOSING INNER CONTENT, FIRST REMOVING CHILDS")
	var content: Array = []
	print("MADE ARRAY FOR CONTENT")
	for i in window_content.get_children():
		content.append(i)
		print("APPENDED CONTENT WITH A CONTENT, REMOVING CHILD")
		window_content.remove_child(i)
		print("REMOVED CHILD")
	print("DONE, PICKING RANDOM CONTENT")
	var b = content.pick_random()
	print("DONE, MAKING CONTENT VISIBLE")
	b.visible = true
	print("DONE, MAKING TITLEBAR MATCH CONTENT")
	title = b.name
	print("DONE, ADDING CHILD")
	window_content.add_child(b)
	print("DONE")

func titlebar_mouse(change: bool) -> void:
	mouse_in_titlebar = change

func titlebar_input(event: InputEvent) -> void:
	if event.is_action_pressed("grab_titlebar") and mouse_held == false:
		mouse_held = true
	elif event.is_action_released("grab_titlebar") and mouse_held:
		mouse_held = false

func _on_close_requested() -> void:
	if current_state:
		visible = false
		current_state = false
		get_parent().remove_child(self)
		won_window.emit(self)

func _process(delta: float) -> void:
	if mouse_in_titlebar and mouse_held and !titlebar_grabbed:
		titlebar_grabbed = true
		current_mouse = get_viewport().get_mouse_position()
	if titlebar_grabbed:
		var mouse_diff: Vector2 = get_viewport().get_mouse_position() - current_mouse
		global_position += mouse_diff
		current_mouse = get_viewport().get_mouse_position()
	if titlebar_grabbed and !mouse_held:
		titlebar_grabbed = false
		current_mouse = Vector2()
