extends Control

signal font_clicked
signal font_selected

@onready var font_button = $FontButton
var id: String = ""
var font_button_size: Vector2 = Vector2(300.0, 40.0)
var send_data: bool = true


func _ready() -> void:
	font_button.button_down.connect(click_font)
	font_button.pressed.connect(select_font)


func init(font_id: String):
	if font_id in FontManager.font_list:
		id = font_id
		font_button.set("theme_override_fonts/font", FontManager.get_font(font_id))
		font_button.text = FontManager.font_list[font_id].title


func click_font():
	if id:
		emit_signal("font_clicked", {"id": id})


func select_font():
	if id:
		emit_signal("font_selected", {"id": id})


func _process(_delta: float) -> void:
	custom_minimum_size = font_button_size
	font_button.size = font_button_size
	size = font_button_size
