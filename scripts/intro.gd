extends Node2D

var cutscene: String = "intro"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if GlobalResources.music_level != GlobalResources.MUSIC_LEVEL.LEVEL_2:
		GlobalResources.music_level = GlobalResources.MUSIC_LEVEL.LEVEL_2
	if Dialogic.current_timeline == null:
		Dialogic.timeline_ended.connect(_on_timeline_ended)
		Dialogic.start(GlobalResources.CUTSCENES[cutscene])

func _on_timeline_ended() -> void:
	Dialogic.timeline_ended.disconnect(_on_timeline_ended)
	if GlobalResources.CUTSCENES_AFTER[cutscene] == GlobalResources.AFTER_CUTSCENE_ACTION.SWITCH_SCENE:
		get_tree().change_scene_to_packed(GlobalResources.CUTSCENE_SWITCH[cutscene])
	elif GlobalResources.CUTSCENES_AFTER[cutscene] == GlobalResources.AFTER_CUTSCENE_ACTION.CONTINUE:
		pass
	else:
		get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
