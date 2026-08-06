extends Microgame

@export var countries: Dictionary[String, Texture]
@onready var hint_label: Label = $CanvasLayer/CenterContainer/HintLabel
@onready var texture_rect: TextureRect = $CanvasLayer/CenterContainer/TextureRect
@onready var enter_area: LineEdit = $CanvasLayer/CenterContainer/EnterArea
@onready var time_left_label: Label = $CanvasLayer/CenterContainer/TimeLeftLabel

var time_left: float = 5
var correct_answer: String
var hint_text: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pick_country()

func pick_country() -> void:
	correct_answer = countries.keys().pick_random()
	texture_rect.texture = countries[correct_answer]
	for i in correct_answer:
		if i.to_upper() != i and i == i.to_lower():
			i = "_"
		if hint_text:
			hint_text += i
		else:
			hint_text = i
	hint_label.text = hint_text

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if time_left > 0.0 and game_playing:
		time_left -= delta
		time_left_label.text = "%.2f" % time_left
	if time_left <= 0.0 and game_playing:
		time_left = 0.0
		time_left_label.text = "0.00"
		game_playing = false
		lose_game.emit()


func _on_enter_area_text_changed(new_text: String) -> void:
	if new_text.to_lower() == correct_answer.to_lower() and game_playing:
		game_playing = false
		win_game.emit()
