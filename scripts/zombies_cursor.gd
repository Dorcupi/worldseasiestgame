extends Sprite2D

const CURSOR_SPEED: float = 650.0
const DEADZONE: float = 0.2

var controller_x_axis: float
var controller_y_axis: float

@export var camera: Camera2D

var starting_global_position: Vector2

func _ready() -> void:
	starting_global_position = get_global_mouse_position()
	global_position = get_viewport_rect().size / 2

func _process(delta: float) -> void:
	#global_rotation = 0
	if GlobalResources.using_controller:
		var move: Vector2 = Vector2(controller_x_axis, controller_y_axis)
		if move.length() < DEADZONE:
			move = Vector2.ZERO
		else:
			move = move.normalized()
		
		#var old_pos: Vector2 = position
		global_position += move * CURSOR_SPEED * delta
		if global_position.x > get_viewport_rect().size.x: global_position.x = get_viewport_rect().size.x
		if global_position.y > get_viewport_rect().size.y: global_position.y = get_viewport_rect().size.y
		if global_position.x < 0: global_position.x = 0
		if global_position.y < 0: global_position.y = 0
		
		#if position != old_pos:
			#var motion_event: InputEventMouseMotion = InputEventMouseMotion.new()
			#motion_event.position = get_cursor_screen_pos()
			#get_viewport().push_input(motion_event)
		
		if Input.is_action_just_pressed("cursor_left_click"):
			var click_event: InputEventAction = InputEventAction.new()
			click_event.action = "attack"
			click_event.pressed = true
			Input.parse_input_event(click_event)
		
		if Input.is_action_just_released("cursor_left_click"):
			var click_event: InputEventAction = InputEventAction.new()
			click_event.action = "attack"
			click_event.pressed = false
			Input.parse_input_event(click_event)

func _input(event: InputEvent) -> void:
	if GlobalResources.using_controller:
		if event is InputEventJoypadMotion:
			if event.axis == JoyAxis.JOY_AXIS_RIGHT_X:
				controller_x_axis = event.axis_value
			elif event.axis == JoyAxis.JOY_AXIS_RIGHT_Y:
				controller_y_axis = event.axis_value
	elif event is InputEventMouseMotion:
		global_position = get_global_mouse_position()
		if global_position.x > get_viewport_rect().size.x: global_position.x = get_viewport_rect().size.x
		if global_position.y > get_viewport_rect().size.y: global_position.y = get_viewport_rect().size.y
		if global_position.x < 0: global_position.x = 0
		if global_position.y < 0: global_position.y = 0

#func get_cursor_screen_pos() -> Vector2:
	#var final_pos: Vector2 = global_position
	#var cam: Camera2D = get_viewport().get_camera_2d()
	#if cam:
		#final_pos -= cam.global_position
		#if cam.anchor_mode == Camera2D.AnchorMode.ANCHOR_MODE_DRAG_CENTER:
			#final_pos += get_viewport_rect().size / 2.0
	#return get_viewport().get_screen_transform().basis_xform(final_pos)

func get_local_ish_position() -> Vector2:
	return global_position - get_viewport_rect().size / 2.0
