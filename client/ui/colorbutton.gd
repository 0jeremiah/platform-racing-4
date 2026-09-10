extends Control

signal colorbutton_color_changed

@onready var color_button = $TextureButton
@onready var colorin = $TextureButton/Colorin
@onready var color_picker_popup = $ColorPickerPopup
@onready var color_picker = $ColorPickerPopup/ColorPicker
var color: Color = Color("000000")
var enabled: bool = true
var spawn_x: float = 0
var spawn_y: float = 0


func _ready() -> void:
	color_button.pressed.connect(_maybe_show_popup)
	color_picker.connect("set_new_color", _change_color)
	colorin.self_modulate = color
	if enabled:
		color_button.self_modulate = Color(1.0, 1.0, 1.0, 1.0)
		colorin.self_modulate = Color(color.r, color.b, color.g, 1.0)
	else:
		color_button.self_modulate = Color(0.5, 0.5, 0.5, 0.75)
		colorin.self_modulate = Color(color.r / 2, color.b / 2, color.g / 2, 0.75)


func set_color(new_color: Color):
	color = new_color
	color_picker._set_color(color)
	colorin.self_modulate = color


func _maybe_show_popup(_spawn_x: float = spawn_x, _spawn_y: float = spawn_y):
	if enabled:
		color_picker.init()
		color_picker.set_previous_color(color)
		color_picker_popup.popup(Rect2(global_position.x + _spawn_x, global_position.y + _spawn_y, 430.0, 452.0))


func _change_color(new_color: Color):
	color = new_color
	if enabled:
		emit_signal("colorbutton_color_changed", color)
	colorin.self_modulate = color
	color_picker_popup.visible = false


func is_enabled(switch: bool):
	enabled = switch
	if enabled:
		color_button.self_modulate = Color(1.0, 1.0, 1.0, 1.0)
		colorin.self_modulate = Color(color.r, color.b, color.g, 1.0)
	else:
		color_button.self_modulate = Color(0.5, 0.5, 0.5, 0.75)
		colorin.self_modulate = Color(color.r / 2, color.b / 2, color.g / 2, 0.75)
