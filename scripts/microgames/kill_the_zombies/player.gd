extends CharacterBody2D

@export var bullet: PackedScene
@export var bullet_spawn_position: Marker2D
@export var speed = 300.0
var can_move: bool = false
@export var shoot_player: AudioStreamPlayer
@export var enemy_hit_player: AudioStreamPlayer
@export var zombies_cursor: CanvasLayer

func _physics_process(delta: float) -> void:

	if not GlobalResources.using_controller: look_at(get_global_mouse_position())
	else: look_at(global_position + zombies_cursor.get_node("Sprite").get_local_ish_position())
	
	if can_move:
		var x_axis_direction := Input.get_axis("move_left", "move_right")
		var y_axis_direction := Input.get_axis("move_up", "move_down")
		var direction: Vector2 = Vector2(x_axis_direction, y_axis_direction).normalized()
		if direction:
			velocity = direction * speed
		else:
			velocity = velocity.move_toward(Vector2.ZERO, speed)
		if Input.is_action_just_pressed("attack"):
			shoot()

	move_and_slide()

func shoot() -> void:
	var bul: Area2D = bullet.instantiate()
	bul.transform = bullet_spawn_position.global_transform
	bul.sound = enemy_hit_player
	owner.add_child(bul)
	shoot_player.play()
