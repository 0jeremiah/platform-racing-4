extends Node2D

@onready var text_box = $Text
var old_position : Vector2
var old_scale : Vector2
var old_mouse_position : Vector2
var buttonSize = 32
var text_string: String = "Text!"
var text_font: String = "poetsenone"
var text_font_size: int = 24
var text_scale: Vector2 = Vector2(1, 1)
var text_position: Vector2 = Vector2(0, 0)
var text_rotation: int = 0
var text_color: String = "071E6BFF"
var edit_text_bg = StyleBoxFlat.new()


# Called when the node enters the scene tree for the first time.
func set_text_properties(text_properties: Dictionary):
	if text_properties.has("text"):
		set_text_string(text_properties.text)
	if text_properties.has("font"):
		set_text_font(text_properties.font)
	if text_properties.has("font_size"):
		set_text_font_size(text_properties.font_size)
	if text_properties.has("scale"):
		set_text_scale(Vector2(text_properties.scale.x, text_properties.scale.y))
	if text_properties.has("position"):
		set_text_position(Vector2(text_properties.position.x, text_properties.position.y))
	if text_properties.has("rotation"):
		set_text_rotation(text_properties.rotation)
	if text_properties.has("color"):
		set_text_color(text_properties.color)


func set_text_string(new_text_string: String):
	text_string = new_text_string
	text_box.text = text_string


func set_text_font(new_text_font: String) -> void:
	var new_font = FontManager.get_font(new_text_font)
	text_box.set("theme_override_fonts/normal_font", new_font)


func set_text_font_size(new_text_font_size: int):
	text_font_size = new_text_font_size
	text_box.set("theme_override_font_sizes/normal_font_size", text_font_size)


func set_text_scale(new_text_scale: Vector2):
	text_scale = new_text_scale
	scale = text_scale


func set_text_position(new_text_position: Vector2):
	text_position = new_text_position
	position = text_position


func set_text_rotation(new_text_rotation: int):
	text_rotation = new_text_rotation
	rotation_degrees = text_rotation


func set_text_color(new_text_color: Color):
	text_color = new_text_color.to_html(false)
	text_box.set("theme_override_colors/default_color", text_color)
