extends CharacterBody2D
var on_screen: bool = true
var can_test_screen: bool = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
var can_jump: bool = false

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

func _ready() -> void:
	animated_sprite.play("default")
	await get_tree().physics_frame
	await get_tree().physics_frame
	await get_tree().physics_frame
	can_test_screen = true

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("bird_jump") and can_jump:
		velocity.y = JUMP_VELOCITY
	
	velocity.x = 0

	move_and_slide()
	if can_test_screen: on_screen = visible_on_screen_notifier_2d.is_on_screen()
