extends Node2D

@onready var main_game: PackedScene = preload("res://scenes/main.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if GlobalResources.music_level != GlobalResources.MUSIC_LEVEL.LEVEL_2:
		GlobalResources.music_level = GlobalResources.MUSIC_LEVEL.LEVEL_2
	if Dialogic.current_timeline == null:
		Dialogic.timeline_ended.connect(_on_timeline_ended)
		Dialogic.start("intro")

func _on_timeline_ended() -> void:
	Dialogic.timeline_ended.disconnect(_on_timeline_ended)
	get_tree().change_scene_to_packed(main_game)
