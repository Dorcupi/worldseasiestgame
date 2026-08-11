extends Node2D

@onready var main_game: PackedScene = load("res://scenes/main.tscn")
@onready var intro: PackedScene = load("res://scenes/intro.tscn")
@onready var settings: PackedScene = load("res://scenes/settings.tscn")
@export var trans_animation_player: AnimationPlayer
@onready var play_button: TextureButton = $CanvasLayer/MarginContainer/VBoxContainer/PlayButton

var prepared_for_controller: bool = false

func _ready() -> void:
	trans_animation_player.play_backwards("fade_out")
	if GlobalResources.music_level != GlobalResources.MUSIC_LEVEL.LEVEL_6:
		GlobalResources.music_level = GlobalResources.MUSIC_LEVEL.LEVEL_6
	GlobalResources.switched_from_keyboard.connect(change_controller)
	if GlobalResources.using_controller:
		prepared_for_controller = true
		play_button.call_deferred("grab_focus")

func change_controller() -> void:
	if not prepared_for_controller:
		prepared_for_controller = true
		play_button.call_deferred("grab_focus")

func _on_play_button_pressed() -> void:
	trans_animation_player.play("fade_out")
	await trans_animation_player.animation_finished
	if GlobalResources.beat_game:
		get_tree().change_scene_to_packed(main_game)
	else:
		get_tree().change_scene_to_packed(intro)


func _on_quit_button_pressed() -> void:
	if GlobalResources.music_level != GlobalResources.MUSIC_LEVEL.OFF:
		GlobalResources.music_level = GlobalResources.MUSIC_LEVEL.OFF 
	trans_animation_player.play("fade_out")
	await trans_animation_player.animation_finished
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)


func _on_settings_button_pressed() -> void:
	trans_animation_player.play("fade_out")
	await trans_animation_player.animation_finished
	get_tree().change_scene_to_packed(settings)
