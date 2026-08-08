extends CharacterBody2D

@export var speed = 450.0
var can_move: bool = false
signal coin_picked_up

func _physics_process(delta: float) -> void:

	look_at(get_global_mouse_position())
	
	if can_move:
		var x_axis_direction := Input.get_axis("move_left", "move_right")
		var y_axis_direction := Input.get_axis("move_up", "move_down")
		var direction: Vector2 = Vector2(x_axis_direction, y_axis_direction).normalized()
		if direction:
			velocity = direction * speed
		else:
			velocity = direction.move_toward(Vector2.ZERO, speed)

	move_and_slide()


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("coins"):
		area.queue_free()
		coin_picked_up.emit()
