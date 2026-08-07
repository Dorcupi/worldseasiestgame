extends Control
signal won_window(window: Control)
var current_state: bool = false

var title: String:
	set(value):
		title = value
		if is_node_ready() and title_label:
			title_label.text = value

var mouse_in_titlebar: bool = false
var mouse_held: bool = false
var titlebar_grabbed: bool = false

var current_mouse: Vector2

@onready var window_content: Control = $MarginContainer2/Control/WindowContent
@onready var title_bar: ColorRect = $MarginContainer2/Control/TitleBar
@onready var title_label: Label = $MarginContainer2/Control/TitleBar/TitleLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("RUNNING SPAWN FUNCTION")
	call_deferred("spawn")
	print("DONE RUNNING SPAWN FUNCTION, ADDING SIGNALS")
	title_bar.mouse_entered.connect(titlebar_mouse.bind(true))
	title_bar.mouse_exited.connect(titlebar_mouse.bind(false))
	title_bar.gui_input.connect(titlebar_input)
	print("DONE ADDING SIGNALS, DONE DONE")

func spawn() -> void: # where some crashes are coming from hypothethically
	print("UPDATING X SIZE")
	custom_minimum_size.x = randi_range(300, 700)
	#size.x = custom_minimum_size.x
	print("DONE, UPDATING Y SIZE")
	custom_minimum_size.y = randi_range(300, 700)
	#size.y = custom_minimum_size.y
	print("DONE, UPDATING X POSITION")
	global_position.x = randf_range(0 - int(custom_minimum_size.x / 2), get_viewport_rect().size.x - int(custom_minimum_size.x / 2))
	print("DONE, UPDATING Y POSITION")
	global_position.y = randf_range(63, get_viewport_rect().size.y - 83)
	print("DONE, WAITING FOR PROCESSING")
	await get_tree().process_frame
	print("DONE, CHOOSING INNER CONTENT, FIRST GETTING CONTENT")
	var content: Array = window_content.get_children()
	if content.is_empty():
		print("NO CONTENT, RETURNING")
		return
	print("DONE, PICKING RANDOM CONTENT")
	var b = content.pick_random()
	print("DONE, MAKING CONTENT VISIBLE AND DELETING OTHERS")
	for i in content:
		if i == b:
			i.visible = true
			title = i.name
		else:
			i.queue_free()
	print("DONE")

func titlebar_mouse(change: bool) -> void:
	mouse_in_titlebar = change

func titlebar_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and !mouse_held:
				mouse_held = true
			elif !event.pressed and mouse_held:
				mouse_held = false
			if mouse_held and mouse_in_titlebar and !titlebar_grabbed:
				titlebar_grabbed = true
			if titlebar_grabbed and !mouse_held:
				titlebar_grabbed = false
	if event is InputEventMouseMotion:
		if titlebar_grabbed:
			global_position += event.screen_relative

func _on_close_requested() -> void:
	if current_state:
		visible = false
		current_state = false
		get_parent().remove_child(self)
		won_window.emit(self)
