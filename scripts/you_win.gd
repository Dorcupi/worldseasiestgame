extends Node2D

@onready var animation_player: AnimationPlayer = $CanvasLayer2/AnimationPlayer
@onready var main_game: PackedScene = preload("res://scenes/main.tscn")
@onready var main_menu: PackedScene = preload("res://scenes/main_menu.tscn")
@onready var play_again_button: TextureButton = $CanvasLayer/Control/VBoxContainer/PlayAgainButton
@onready var glitch_grayscale: ColorRect = $CanvasLayer/GlitchGrayscale

@export var time_spent_label: Label
@export var microgames_won_label: Label
@export var new_pb_label: Label

var prepared_for_controller: bool = false

@onready var cutscene_ready: bool = GlobalResources.after_cutscene_ready
@onready var playing_cutscene: bool = cutscene_ready
var cutscene: String

func _ready() -> void:
	new_pb_label.visible = GlobalResources.beat_pb
	time_spent_label.text = "Time Spent: %.0fs" % GlobalResources.current_time
	microgames_won_label.text = "Microgames Won: %.0f" % GlobalResources.current_microgames_won
	if GlobalResources.music_level != GlobalResources.MUSIC_LEVEL.LEVEL_5:
			GlobalResources.music_level = GlobalResources.MUSIC_LEVEL.LEVEL_5
	animation_player.play_backwards("fade_out")
	if cutscene_ready:
		cutscene = GlobalResources.after_cutscene
		glitch_grayscale.blocking_input = true
		if animation_player.is_playing():
			await animation_player.animation_finished
		Dialogic.timeline_ended.connect(_on_timeline_ended)
		Dialogic.start(GlobalResources.CUTSCENES[cutscene])
	else:
		glitch_grayscale.blocking_input = false
	GlobalResources.switched_from_keyboard.connect(change_controller)
	if GlobalResources.using_controller and not playing_cutscene:
		prepared_for_controller = true
		play_again_button.call_deferred("grab_focus")

func change_controller() -> void:
	if not prepared_for_controller and not playing_cutscene:
		prepared_for_controller = true
		play_again_button.call_deferred("grab_focus")

func _on_play_again_button_pressed() -> void:
	animation_player.play("fade_out")
	await animation_player.animation_finished
	get_tree().change_scene_to_packed(main_game)


func _on_back_to_menu_button_pressed() -> void:
	animation_player.play("fade_out")
	await animation_player.animation_finished
	get_tree().change_scene_to_packed(main_menu)

func _on_timeline_ended() -> void:
	playing_cutscene = false
	if GlobalResources.CUTSCENES_AFTER[cutscene] == GlobalResources.AFTER_CUTSCENE_ACTION.SWITCH_SCENE:
		get_tree().change_scene_to_packed(GlobalResources.CUTSCENE_SWITCH[cutscene])
	elif GlobalResources.CUTSCENES_AFTER[cutscene] == GlobalResources.AFTER_CUTSCENE_ACTION.CONTINUE:
		if GlobalResources.using_controller:
			prepared_for_controller = true
			play_again_button.call_deferred("grab_focus")
		glitch_grayscale.blocking_input = false
	else:
		get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
