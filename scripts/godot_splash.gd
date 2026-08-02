extends Node2D

@export var scene: PackedScene

func _ready() -> void:
	$AnimationPlayer.play("godot-splash")
	if GlobalResources.music_level != GlobalResources.MUSIC_LEVEL.LEVEL_3:
		GlobalResources.music_level = GlobalResources.MUSIC_LEVEL.LEVEL_3

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "godot-splash":
		get_tree().change_scene_to_packed(scene)
