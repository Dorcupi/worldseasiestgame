extends Node2D
class_name MainGame

enum GAME_STATE {
	MAIN_SCENE,
	MOVING_TO,
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
@export var popup_spawner: Node2D

## Audio Nodes
@export var button_alarm_player: AudioStreamPlayer
@export var door_open_player: AudioStreamPlayer
@export var door_close_player: AudioStreamPlayer
@export var win_piano_player: AudioStreamPlayer
@export var lose_piano_player: AudioStreamPlayer
@export var clock_tick_player: AudioStreamPlayer
@export var heart_beat_player: AudioStreamPlayer

## Variables
@export var add_time_popup: PackedScene
@export var microgames: Array[PackedScene]
@onready var unplayed_microgames: Array[PackedScene] = microgames.duplicate()
@export var starting_time: float = 60.0
@export var start_add_amount: Array[float] = [3, 5]
@onready var time_left: float = starting_time
@onready var once_second_time: int = int(time_left)
var time_spent: float = 0
var microgames_won: int = 0
var current_state: GAME_STATE = GAME_STATE.MAIN_SCENE:
	set(value):
		current_state = value
		on_state_switch(value)
		
var current_microgame: Microgame
var add_amount: Array[float] = start_add_amount
var level: int = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalResources.music_transition_time = 1
	GlobalResources.switched_from_keyboard.connect(on_controller_active)
	microgame_button.button.pressed.connect(start_microgame)
	current_state = GAME_STATE.MAIN_SCENE
	trans_animation_player.play_backwards("fade_out")

func on_controller_active() -> void:
	if current_state == GAME_STATE.MAIN_SCENE:
		microgame_button.button.call_deferred("grab_focus")

func on_state_switch(state: GAME_STATE) -> void:
	match state:
		GAME_STATE.MAIN_SCENE:
			microgame_button.button.call_deferred("grab_focus")

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
			GlobalResources.update_time(time_spent, microgames_won)
			GlobalResources.music_transition_time = 2
			trans_animation_player.play("fade_out")
			await trans_animation_player.animation_finished
			if lose_piano_player.playing: await lose_piano_player.finished
			get_tree().change_scene_to_file("res://scenes/you_win.tscn")
	elif current_state == GAME_STATE.MINIGAME:
		if time_left <= 0.0 and current_microgame and current_microgame.game_playing:
			current_microgame.emit_signal("lose_game")

func once_per_second() -> void:
	clock_tick_player.play()
	if current_state == GAME_STATE.MINIGAME:
		heart_beat_player.play()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		pause_menu.trigger_pause()

func spawn_microgame() -> void:
	if not unplayed_microgames.is_empty():
		print("NO LEVEL UP NEEDED, PICKING GAME")
		var microgame_scene = unplayed_microgames.pick_random()
		unplayed_microgames.erase(microgame_scene)
		print("DONE, INSTANCING GAME")
		current_microgame = microgame_scene.instantiate()
	else:
		print("LEVEL UP NEEDED, WAITING FOR LEVEL UP")
		await level_up()
		print("DONE, PICKING GAME")
		var microgame_scene = unplayed_microgames.pick_random()
		unplayed_microgames.erase(microgame_scene)
		print("DONE, INSTANCING GAME")
		current_microgame = microgame_scene.instantiate()
	print("DONE, CONNECTING SIGNALS")
	current_microgame.win_game.connect(win_microgame)
	current_microgame.lose_game.connect(lose_microgame)
	print("DONE, TELLING MICROGAME LEVEL")
	current_microgame.level = level
	print("DONE, ADDING MICROGAME AS CHILD")
	microgame_spawner.add_child(current_microgame)
	print("DONE, CHECKING TO SEE IF READY")
	if not current_microgame.is_node_ready():
		print("HAVE TO WAIT FOR READY")
		await current_microgame.ready
	print("DONE DONE MICROGAME SPAWNING")

func spawn_add_time_popup(text: String) -> void:
	var popup = add_time_popup.instantiate()
	popup.message = text
	popup.global_position.x = randf_range(140, get_viewport_rect().size.x - 140)
	popup.global_position.y = randf_range(140, get_viewport_rect().size.y - 140)
	popup_spawner.add_child(popup)

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
		current_state = GAME_STATE.MOVING_TO
		print("SPAWNING MICROGAME")
		await spawn_microgame()
		print("FINISHED, ADJUSTING MUSIC")
		if GlobalResources.music_level != GlobalResources.MUSIC_LEVEL.LEVEL_2:
			GlobalResources.music_level = GlobalResources.MUSIC_LEVEL.LEVEL_2
		print("FINISHED, SPAWNING POPUP")
		game_name_popup.text = current_microgame.game_name
		game_name_popup.get_node("AnimationPlayer").play("appear")
		print("FINISHED, OPENING DOOR")
		door_open_player.play()
		main_animation_player.play("break_apart")
		print("FINISHED, WAITING FOR DOOR TO OPEN")
		while main_animation_player.is_playing():
			await get_tree().process_frame
		print("FINISHED, SETTING GAME PLAYING TO TRUE")
		current_microgame.game_playing = true
		print("DONE FINISHED DONE")
		current_state = GAME_STATE.MINIGAME

func win_microgame() -> void:
	if current_state == GAME_STATE.MINIGAME:
		var added_time: float = snapped(randf_range(add_amount[0], add_amount[1]), 0.5)
		time_left += added_time
		microgames_won += 1
		once_second_time += ceil(added_time)
		spawn_add_time_popup("+%.1f" % added_time)
		current_state = GAME_STATE.MOVING_BACK
		door_close_player.play()
		win_piano_player.play()
		main_animation_player.play_backwards("break_apart")
		await main_animation_player.animation_finished
		despawn_microgame()
		current_state = GAME_STATE.MAIN_SCENE

func lose_microgame() -> void:
	if current_state == GAME_STATE.MINIGAME:
		current_state = GAME_STATE.MOVING_BACK
		door_close_player.play()
		lose_piano_player.play()
		main_animation_player.play_backwards("break_apart")
		await main_animation_player.animation_finished
		despawn_microgame()
		current_state = GAME_STATE.MAIN_SCENE
