extends Node2D

@onready var animation_player: AnimationPlayer = $CanvasLayer2/AnimationPlayer
@onready var main_game: PackedScene = preload("res://scenes/main.tscn")
@onready var main_menu: PackedScene = preload("res://scenes/main_menu.tscn")

@export var time_spent_label: Label
@export var new_pb_label: Label

func _ready() -> void:
	new_pb_label.visible = GlobalResources.beat_pb
	time_spent_label.text = "Time Spent: %.0fs" % GlobalResources.current_time
	if GlobalResources.music_level != GlobalResources.MUSIC_LEVEL.LEVEL_5:
			GlobalResources.music_level = GlobalResources.MUSIC_LEVEL.LEVEL_5
	animation_player.play_backwards("fade_out")

func _on_play_again_button_pressed() -> void:
	animation_player.play("fade_out")
	await animation_player.animation_finished
	get_tree().change_scene_to_packed(main_game)


func _on_back_to_menu_button_pressed() -> void:
	animation_player.play("fade_out")
	await animation_player.animation_finished
	get_tree().change_scene_to_packed(main_menu)
