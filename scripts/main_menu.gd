extends Node2D

@onready var main_game: PackedScene = preload("res://scenes/main.tscn")
@export var trans_animation_player: AnimationPlayer

func _ready() -> void:
	trans_animation_player.play_backwards("fade_out")
	if GlobalResources.music_level != GlobalResources.MUSIC_LEVEL.LEVEL_6:
		GlobalResources.music_level = GlobalResources.MUSIC_LEVEL.LEVEL_6

func _on_play_button_pressed() -> void:
	trans_animation_player.play("fade_out")
	await trans_animation_player.animation_finished
	get_tree().change_scene_to_packed(main_game)


func _on_quit_button_pressed() -> void:
	if GlobalResources.music_level != GlobalResources.MUSIC_LEVEL.OFF:
		GlobalResources.music_level = GlobalResources.MUSIC_LEVEL.OFF 
	trans_animation_player.play("fade_out")
	await trans_animation_player.animation_finished
	get_tree().quit()
