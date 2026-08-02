extends StaticBody2D
@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var area_2d: Area2D = $Area2D
var on_screen: bool = false
var pipe_min: int = -112
var pipe_max: int = 218
@export var starting_gap: int = 1
signal player_passed
var can_move: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area_2d.area_entered.connect(on_area_entered)
	respawn(starting_gap)
	on_screen = visible_on_screen_notifier_2d.is_on_screen()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if can_move: position.x -= 250 * delta
	if visible_on_screen_notifier_2d.is_on_screen() and not on_screen:
		on_screen = true
	if !visible_on_screen_notifier_2d.is_on_screen() and on_screen:
		respawn()
		on_screen = false

func on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		player_passed.emit()

func respawn(gap: int = 1) -> void:
	var canvas_width: float = get_viewport_rect().size.x
	position.x = canvas_width + (83 * gap)
	position.y = randf_range(float(pipe_min), float(pipe_max))
