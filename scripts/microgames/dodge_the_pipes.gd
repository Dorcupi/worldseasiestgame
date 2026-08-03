extends Microgame

@export var background_animation_player: AnimationPlayer
@export var player: CharacterBody2D
@export var score_label: Label

var passes_left: int = randi_range(level + 1, level + 3)

var game_state: bool = false:
	set(value):
		game_state = value
		player.can_jump = value
		for i in get_tree().get_nodes_in_group("pipes"):
			i.can_move = value

var started_game: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.can_jump = game_state
	for i in get_tree().get_nodes_in_group("pipes"):
		if not i.player_passed.is_connected(on_player_pass):
			i.player_passed.connect(on_player_pass)
			i.can_move = game_state
	background_animation_player.play("scroll")

func on_player_pass() -> void:
	if passes_left != 0: passes_left -= 1
	if passes_left <= 0:
		game_state = false
		win_game.emit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if game_playing and not game_state and not started_game:
		game_state = true
		started_game = true
	if not player.on_screen:
		game_state = false
		lose_game.emit()
	score_label.text = str(passes_left)
