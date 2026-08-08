extends Microgame

@export var time_left_label: Label
@export var timer: Timer
@export var clicks_left_label: Label
@export var audio_stream_player: AudioStreamPlayer
@export var button: TextureButton


var number_of_clicks_needed: float
var clicks: float

func _ready() -> void:
	number_of_clicks_needed = clamp(randi_range(level, level + 4), 1, 15)
	clicks = number_of_clicks_needed
	button.call_deferred("grab_focus")

func _process(delta: float) -> void:
	if game_playing:
		if timer.is_stopped():
			timer.start(2)
		time_left_label.text = "%.2f" % timer.time_left
		clicks_left_label.text = "%.0f" % clicks

func _on_timer_timeout() -> void:
	if clicks == 0:
		win_game.emit()
	else:
		lose_game.emit()


func _on_button_pressed() -> void:
	clicks -= 1
	if clicks < 0:
		audio_stream_player.pitch_scale = 0.5
	else:
		audio_stream_player.pitch_scale = 1
	audio_stream_player.play()
