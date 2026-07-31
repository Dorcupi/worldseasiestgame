extends Node2D

@export var scene_to_switch: PackedScene

func _ready() -> void:
	$AnimationPlayer.play("splash")
	if GlobalResources.music_level != GlobalResources.MUSIC_LEVEL.LEVEL_3:
		GlobalResources.music_level = GlobalResources.MUSIC_LEVEL.LEVEL_3

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "splash":
		get_tree().change_scene_to_packed(scene_to_switch)
