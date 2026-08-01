extends CanvasLayer
@export var trans_animation_player: AnimationPlayer
@onready var main_menu: PackedScene = load("res://scenes/main_menu.tscn")

var paused: bool = false

func pause() -> void:
	paused = true
	visible = true
	get_tree().paused = true

func unpause(keep_visible: bool = false) -> void:
	paused = false
	visible = keep_visible
	get_tree().paused = false

func trigger_pause() -> void:
	if paused: unpause()
	else: pause()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"): trigger_pause()

func _on_resume_button_pressed() -> void:
	unpause()


func _on_back_to_menu_button_pressed() -> void:
	unpause(true)
	get_tree().current_scene.current_state = get_tree().current_scene.GAME_STATE.GAME_OVER
	trans_animation_player.play("fade_out")
	await trans_animation_player.animation_finished
	get_tree().change_scene_to_packed(main_menu)


func _on_quit_button_pressed() -> void:
	unpause(true)
	get_tree().current_scene.current_state = get_tree().current_scene.GAME_STATE.GAME_OVER
	trans_animation_player.play("fade_out")
	await trans_animation_player.animation_finished
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
