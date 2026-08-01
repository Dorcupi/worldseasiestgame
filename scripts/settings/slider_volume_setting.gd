extends HBoxContainer

@onready var title_label: Label = $TitleLabel
@onready var h_slider: HSlider = $HSlider
@onready var value_label: Label = $ValueLabel

@export var setting_name: String
@export var setting_description: String
@export var bus_name: String
var bus_index: int

func _ready() -> void:
	title_label.text = setting_name
	bus_index = AudioServer.get_bus_index(bus_name)
	h_slider.value = AudioServer.get_bus_volume_linear(bus_index)

func _on_h_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	value_label.text = "%.2f" % value
