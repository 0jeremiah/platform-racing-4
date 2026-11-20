extends Control

signal colorbutton_color_changed

@onready var color_picker_popup = preload("res://ui/colorpicker/colorpickerpopup.gd")
@onready var color_button = $TextureButton
@onready var color_texture = $TextureButton/ColorTexture
var color: Color = Color("FFFFFF")
var enabled: bool = true
var parent: Node = null


func _ready() -> void:
	color_button.pressed.connect(_maybe_show_popup)
	color_texture.self_modulate = color
	if enabled:
		color_button.self_modulate = Color(1.0, 1.0, 1.0, 1.0)
		color_texture.self_modulate = Color(color.r, color.b, color.g, 1.0)
	else:
		color_button.self_modulate = Color(0.5, 0.5, 0.5, 0.75)
		color_texture.self_modulate = Color(color.r / 2, color.b / 2, color.g / 2, 0.75)


func set_color(new_color: Color):
	color = new_color
	color_texture.self_modulate = color


func _maybe_show_popup():
	if enabled:
		PopupManager.add_custom_popup(color_picker_popup, {"colorpicker_func": Callable(self, "_change_color"), "previous_color": color, "popup_global_position": Vector2(global_position.x + size.x, global_position.y)}, self if parent is not Node else parent)


func _change_color(new_color: Color):
	color = new_color
	if enabled:
		emit_signal("colorbutton_color_changed", color)
	color_texture.self_modulate = color


func is_enabled(switch: bool):
	enabled = switch
	if enabled:
		color_button.self_modulate = Color(1.0, 1.0, 1.0, 1.0)
		color_texture.self_modulate = Color(color.r, color.b, color.g, 1.0)
	else:
		color_button.self_modulate = Color(0.5, 0.5, 0.5, 0.75)
		color_texture.self_modulate = Color(color.r / 2, color.b / 2, color.g / 2, 0.75)


func set_color_button_scale(new_color_button_scale: Vector2):
	color_button.scale = new_color_button_scale
	size = color_button.size * color_button.scale
