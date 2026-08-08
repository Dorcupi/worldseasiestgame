extends Node2D

@export var trans_animation_player: AnimationPlayer
@onready var main_menu: PackedScene = load("res://scenes/main_menu.tscn")
@onready var master_volume: HBoxContainer = $CanvasLayer/MarginContainer/VBoxContainer/MasterVolume

var prepared_for_controller: bool = false

func _ready() -> void:
	GlobalResources.entered_settings = true
	if !GlobalResources.past_splash:
		GlobalResources.past_splash = true
	trans_animation_player.play_backwards("fade_out")
	if GlobalResources.music_level != GlobalResources.MUSIC_LEVEL.LEVEL_5:
		GlobalResources.music_level = GlobalResources.MUSIC_LEVEL.LEVEL_5
	GlobalResources.switched_from_keyboard.connect(change_controller)
	if GlobalResources.using_controller:
		prepared_for_controller = true
		master_volume.h_slider.call_deferred("grab_focus")

func change_controller() -> void:
	if not prepared_for_controller:
		prepared_for_controller = true
		master_volume.h_slider.call_deferred("grab_focus")


func _on_back_to_menu_button_pressed() -> void:
	trans_animation_player.play("fade_out")
	await trans_animation_player.animation_finished
	get_tree().change_scene_to_packed(main_menu)
