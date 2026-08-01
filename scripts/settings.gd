extends Node2D

@export var trans_animation_player: AnimationPlayer
@onready var main_menu: PackedScene = load("res://scenes/main_menu.tscn")

func _ready() -> void:
	trans_animation_player.play_backwards("fade_out")
	if GlobalResources.music_level != GlobalResources.MUSIC_LEVEL.LEVEL_5:
		GlobalResources.music_level = GlobalResources.MUSIC_LEVEL.LEVEL_5


func _on_back_to_menu_button_pressed() -> void:
	trans_animation_player.play("fade_out")
	await trans_animation_player.animation_finished
	get_tree().change_scene_to_packed(main_menu)
