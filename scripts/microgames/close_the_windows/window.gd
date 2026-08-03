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
	spawn()
	title_bar.mouse_entered.connect(titlebar_mouse.bind(true))
	title_bar.mouse_exited.connect(titlebar_mouse.bind(false))
	title_bar.gui_input.connect(titlebar_input)

func spawn() -> void:
	size.x = randi_range(300, 700)
	size.y = randi_range(300, 700)
	global_position.x = randi_range(0 - int(size.x / 2), get_viewport_rect().size.x - int(size.x / 2))
	global_position.y = randi_range(0, get_viewport_rect().size.y - 83)
	for i in window_content.get_children():
		i.visible = false
	var b = window_content.get_children().pick_random()
	b.visible = true
	title = b.name

func titlebar_mouse(change: bool) -> void:
	mouse_in_titlebar = change
	print(change)

func titlebar_input(event: InputEvent) -> void:
	if event.is_action_pressed("grab_titlebar") and mouse_held == false:
		mouse_held = true
	elif event.is_action_released("grab_titlebar") and mouse_held:
		mouse_held = false

func _on_close_requested() -> void:
	if current_state:
		visible = false
		current_state = false
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
