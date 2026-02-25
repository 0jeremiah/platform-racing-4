extends Control

@onready var label_text = $LabelText

var action_man_font = preload("res://fonts/actionman/action-man.ttf")
var arial_font = preload("res://fonts/arial/arial.ttf")
var gwibble_font = preload("res://fonts/gwibble/gwibble.ttf")
var poetsenone_font = preload("res://fonts/poetsenone/poetsenone-regular.ttf")
var quicksand_font = preload("res://fonts/quicksand/quicksand-variablefont_wght.ttf")
var verdana_font = preload("res://fonts/verdana/verdana.ttf")
var old_position : Vector2
var old_scale : Vector2
var old_mouse_position : Vector2
var buttonSize = 32
var text_string: String = "Text!"
var text_font: String = "poetsenone"
var text_font_size: int = 24
var text_size: Vector2 = Vector2(1, 1)
var text_position: Vector2 = Vector2(0, 0)
var text_rotation: int = 0
var text_color: Color = Color("071E6BFF")
var edit_text_bg = StyleBoxFlat.new()
var font_list = {
	"poetsenone": {
		"title": "Poetsen One",
		"font": poetsenone_font
	},
	"arial": {
		"title": "Arial",
		"font": arial_font
	},
	"verdana": {
		"title": "Verdana",
		"font": verdana_font
	},
	"actionman": {
		"title": "Action Man",
		"font": action_man_font
	},
	"gwibble": {
		"title": "Gwibble",
		"font": gwibble_font
	},
	"quicksand": {
		"title": "Quicksand",
		"font": quicksand_font
	}
}

# Called when the node enters the scene tree for the first time.
func set_text_properties(text_properties: Dictionary):
	if text_properties.has("text"):
		set_text_string(text_properties.text)
	if text_properties.has("font"):
		set_text_font(text_properties.font)
	if text_properties.has("font_size"):
		set_text_font_size(text_properties.font_size)
	if text_properties.has("size"):
		set_text_size(Vector2(text_properties.size.x, text_properties.size.y))
	if text_properties.has("position"):
		set_text_position(Vector2(text_properties.position.x, text_properties.position.y))
	if text_properties.has("rotation"):
		set_text_rotation(text_properties.rotation)
	if text_properties.has("color"):
		set_text_color(text_properties.color)


func set_text_string(new_text_string: String):
	text_string = new_text_string
	label_text.text = text_string


func set_text_font(new_text_font: String) -> void:
	if font_list.has(new_text_font):
		text_font = new_text_font
	else:
		text_font = "poetsenone"
	label_text.set("theme_override_fonts/normal_font", font_list[text_font].font)


func set_text_font_size(new_text_font_size: int):
	text_font_size = new_text_font_size
	label_text.set("theme_override_font_sizes/normal_font_size", text_font_size)


func set_text_size(new_text_size: Vector2):
	text_size = new_text_size
	label_text.scale = text_size


func set_text_position(new_text_position: Vector2):
	text_position = new_text_position
	label_text.position = text_position


func set_text_rotation(new_text_rotation: int):
	text_rotation = new_text_rotation
	label_text.rotation_degrees = text_rotation


func set_text_color(new_text_color: Color):
	text_color = new_text_color
	label_text.set("theme_override_colors/default_color", text_color)
