extends ColorRect

@export var glitch_enabled: bool = false:
	set(value):
		glitch_enabled = value
		update()
@export var monochrome_enabled: bool = false:
	set(value):
		monochrome_enabled = value
		update()
@export var blocking_input: bool = false:
	set(value):
		blocking_input = value
		update()

var input_variable: String = "mouse_filter"
var blocked_input_filter: MouseFilter = MOUSE_FILTER_STOP
var allowed_input_filter: MouseFilter = MOUSE_FILTER_IGNORE

var shader_glitch_param: String = "enable_glitch"
var shader_monochrome_param: String = "enable_monochrome"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update()

func update() -> void:
	self.set(input_variable, blocked_input_filter if blocking_input else allowed_input_filter)
	set_instance_shader_parameter(shader_glitch_param, glitch_enabled)
	set_instance_shader_parameter(shader_monochrome_param, monochrome_enabled)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
