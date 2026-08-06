extends Microgame

var button_worth: float
var lose_worth: float
var current_value: float = 0
var left_zero: bool = false
@onready var player: TextureRect = $CanvasLayer/HBoxContainer/Control/Player
@onready var progress_bar: ProgressBar = $CanvasLayer/Control/ProgressBar
@onready var timer: Timer = $Timer

@export var empty_image: Texture
@export var half_image: Texture
@export var full_image: Texture

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button_worth = 15.0 / (float(level) / 2)
	lose_worth = 1 * clamp(float(level), 0.0, 10.0)
	print(lose_worth)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	progress_bar.value = current_value
	if game_playing:
		if !left_zero and current_value > 0:
			left_zero = true
		if left_zero: current_value -= (delta * lose_worth)
		if current_value <= 0 and left_zero:
			game_playing = false
			lose_game.emit() 
	if current_value < 50:
		player.texture = empty_image
	elif current_value >= 50 and current_value < 100:
		player.texture = half_image
	elif current_value >= 100:
		player.texture = full_image


func _on_button_pressed() -> void:
	if game_playing:
		current_value += button_worth
		if current_value >= 100:
			current_value = 100
			game_playing = false
			timer.start(0.25)


func _on_timer_timeout() -> void:
	win_game.emit()
