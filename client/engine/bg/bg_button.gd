extends Control

signal bg_selected

@onready var bg_button = $BGButton
var id: String = ""
var bg_size: float = 48.0


func _ready() -> void:
	bg_button.pressed.connect(select_bg)


func init(bg_id: String):
	if bg_id in Backgrounds.bg_dictionary:
		id = bg_id
		bg_button.texture_normal = Backgrounds.bg_dictionary[id].texture


func select_bg():
	if id:
		emit_signal("bg_selected", id)


func _process(_delta: float) -> void:
	custom_minimum_size = Vector2(bg_size * 1.25, bg_size * 1.25)
	bg_button.size = Vector2(bg_size, bg_size)
	bg_button.pivot_offset = Vector2(bg_button.size.x / 2, bg_button.size.y / 2)
	size = Vector2(bg_size * 1.25, bg_size * 1.25)
	bg_button.position = Vector2((size.x - bg_button.size.x) / 2, (size.y - bg_button.size.y) / 2)
	if bg_button.visible and bg_button.is_hovered():
		if bg_button.is_pressed():
			bg_button.scale = Vector2(1, 1)
			bg_button.self_modulate = Color(0.75, 0.75, 0.75)
		else:
			bg_button.scale = Vector2(1.25, 1.25)
			bg_button.self_modulate = Color(1.25, 1.25, 1.25)
	else:
		bg_button.scale = Vector2(1, 1)
		bg_button.self_modulate = Color(1, 1, 1)
