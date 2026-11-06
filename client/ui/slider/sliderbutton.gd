extends Control
class_name SliderButton

signal slider_value_changed

@onready var slider_popup = preload("res://ui/slider/slider_popup.gd")
@onready var slider_holder = $SliderHolder
@onready var label_text = $SliderHolder/LabelText
@onready var value_text = $SliderHolder/ValueText
@onready var slider_button = $SliderHolder/SliderButton
var slider_label: String = "Label"
var slider_value = 1
var min_value = 0
var max_value = 100


func _ready() -> void:
	slider_button.pressed.connect(_show_slider_popup)


func _process(_delta: float) -> void:
	if visible and slider_button.is_hovered() and !slider_button.is_pressed():
		slider_holder.scale = Vector2(1.25, 1.25)
	else:
		slider_holder.scale = Vector2(1, 1)


func set_button(label: String, new_slider_value: int, new_min_value: int, new_max_value: int):
	label_text.text = label
	slider_value = new_slider_value
	min_value = new_min_value
	max_value = new_max_value
	value_text.text = str(new_slider_value)


func _show_slider_popup():
	PopupManager.add_custom_popup(slider_popup, {"slider_func": Callable(self, "_set_slider_value"), "slider_size": Vector2(250.0, 60.0), "init_slider_values": {"current_value": slider_value, "min_value": min_value, "max_value": max_value, "is_int": slider_value is int}, "popup_global_position": Vector2(global_position.x + size.x + 20, global_position.y)}, self)


func _set_slider_value(new_slider_value):
	if new_slider_value is float or new_slider_value is int:
		slider_value = new_slider_value
		value_text.text = str(slider_value)
		emit_signal("slider_value_changed", slider_value)
