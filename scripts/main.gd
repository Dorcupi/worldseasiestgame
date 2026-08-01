extends Node2D
class_name MainGame

enum GAME_STATE {
	MAIN_SCENE,
	MINIGAME,
	MOVING_BACK,
	GAME_OVER,
}

# -- CANVAS LAYER HEIRACRCHY --
# 999: Main Game Screen
#
# 2: Non-Canvas Layer Game UI Elements
# 1: Entire Game Canvas Layer

## Nodes
@export var time_left_label: Label
@export var microgame_button: MicrogameButton
@export var main_animation_player: AnimationPlayer
@export var microgame_spawner: Node2D
@export var game_name_popup: Label
@export var level_up_popup: Label
@onready var trans_animation_player: AnimationPlayer = $CanvasLayer2/AnimationPlayer
@export var pause_menu: CanvasLayer

## Audio Nodes
@export var button_alarm_player: AudioStreamPlayer
@export var door_open_player: AudioStreamPlayer
@export var door_close_player: AudioStreamPlayer
@export var win_piano_player: AudioStreamPlayer
@export var lose_piano_player: AudioStreamPlayer
@export var clock_tick_player: AudioStreamPlayer
@export var heart_beat_player: AudioStreamPlayer

## Variables
@export var microgames: Array[PackedScene]
@onready var unplayed_microgames: Array[PackedScene] = microgames.duplicate()
@export var starting_time: float = 60.0
@export var start_add_amount: Array[float] = [3, 5]
@onready var time_left: float = starting_time
@onready var once_second_time: int = int(time_left)
var time_spent: float = 0
var current_state: GAME_STATE = GAME_STATE.MAIN_SCENE
var current_microgame: Microgame
var add_amount: Array[float] = start_add_amount
var level: int = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalResources.music_transition_time = 1
	microgame_button.button.pressed.connect(start_microgame)
	trans_animation_player.play_backwards("fade_out")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if current_state != GAME_STATE.GAME_OVER:
		time_left -= delta
		time_spent += delta
		if time_left > 0.0:
			if float(once_second_time) - time_left >= 1.00:
				once_second_time -= 1
				once_per_second()
	time_left_label.text = "%.0f" % ceil(time_left)
	if current_state == GAME_STATE.MAIN_SCENE:
		if GlobalResources.music_level != GlobalResources.MUSIC_LEVEL.LEVEL_4:
			GlobalResources.music_level = GlobalResources.MUSIC_LEVEL.LEVEL_4
		if time_left <= 0.0:
			current_state = GAME_STATE.GAME_OVER
			GlobalResources.update_time(time_spent)
			GlobalResources.music_transition_time = 2
			trans_animation_player.play("fade_out")
			await trans_animation_player.animation_finished
			get_tree().change_scene_to_file("res://scenes/you_win.tscn")
	elif current_state == GAME_STATE.MINIGAME:
		if time_left <= 0.0:
			current_microgame.emit_signal("lose_game")

func once_per_second() -> void:
	print("TICK")
	clock_tick_player.play()
	if current_state == GAME_STATE.MINIGAME:
		heart_beat_player.play()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		pause_menu.trigger_pause()

func spawn_microgame() -> void:
	var microgame: Node
	if not unplayed_microgames.is_empty():
		var microgame_scene = unplayed_microgames.pick_random()
		unplayed_microgames.erase(microgame_scene)
		microgame = microgame_scene.instantiate()
	else:
		await level_up()
		var microgame_scene = unplayed_microgames.pick_random()
		unplayed_microgames.erase(microgame_scene)
		microgame = microgame_scene.instantiate()
	microgame.win_game.connect(win_microgame)
	microgame.lose_game.connect(lose_microgame)
	current_microgame = microgame
	microgame_spawner.add_child(microgame)

func level_up() -> void:
	# insert code here to make game harder
	level += 1
	for i in add_amount:
		if not i <= 0.5:
			add_amount[add_amount.find(i)] = (i - 0.5)
	unplayed_microgames = microgames.duplicate()
	button_alarm_player.play()
	level_up_popup.get_node("AnimationPlayer").play("popup")
	await level_up_popup.get_node("AnimationPlayer").animation_finished

func despawn_microgame() -> void:
	current_microgame.queue_free()
	current_microgame = null

func start_microgame() -> void:
	if current_state == GAME_STATE.MAIN_SCENE:
		current_state = GAME_STATE.MINIGAME
		await spawn_microgame()
		if GlobalResources.music_level != GlobalResources.MUSIC_LEVEL.LEVEL_2:
			GlobalResources.music_level = GlobalResources.MUSIC_LEVEL.LEVEL_2
		game_name_popup.text = current_microgame.game_name
		game_name_popup.get_node("AnimationPlayer").play("appear")
		door_open_player.play()
		main_animation_player.play("break_apart")
		await main_animation_player.animation_finished
		current_microgame.game_playing = true

func win_microgame() -> void:
	if current_state == GAME_STATE.MINIGAME:
		print("WIN GAME")
		var added_time: float = snapped(randf_range(add_amount[0], add_amount[1]), 0.5)
		time_left += added_time
		once_second_time += ceil(added_time)
		current_state = GAME_STATE.MOVING_BACK
		door_close_player.play()
		win_piano_player.play()
		main_animation_player.play_backwards("break_apart")
		await main_animation_player.animation_finished
		despawn_microgame()
		current_state = GAME_STATE.MAIN_SCENE

func lose_microgame() -> void:
	if current_state == GAME_STATE.MINIGAME:
		print("LOSE GAME")
		current_state = GAME_STATE.MOVING_BACK
		door_close_player.play()
		lose_piano_player.play()
		main_animation_player.play_backwards("break_apart")
		await main_animation_player.animation_finished
		despawn_microgame()
		current_state = GAME_STATE.MAIN_SCENE
