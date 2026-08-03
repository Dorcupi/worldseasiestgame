extends Node2D
@export var message: String
@onready var label: Label = $Label
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.text = message
	animation_player.play("popup")
	animation_player.connect("animation_finished", func(anim_name: String): queue_free())
