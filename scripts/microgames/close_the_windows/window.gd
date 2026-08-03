extends Window
signal won_window(window: Window)
var current_state: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn()

func spawn() -> void:
	size.x = randi_range(300, 700)
	size.y = randi_range(300, 700)
	position.x = randi_range(0 - int(size.x / 2), get_parent().get_viewport_rect().size.x + int(size.x / 2))
	position.y = randi_range(36, get_parent().get_viewport_rect().size.y)
	for i in get_children():
		i.visible = false
	var b = get_children().pick_random()
	b.visible = true
	title = b.name

func _on_close_requested() -> void:
	if current_state:
		hide()
		current_state = false
		won_window.emit(self)
