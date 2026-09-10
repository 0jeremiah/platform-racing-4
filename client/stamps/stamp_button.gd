extends Control

signal stamp_clicked
signal stamp_selected

@onready var stamp_button = $StampButton
var id: String = ""
var stamp_size: float = 48.0
var send_data: bool = true


func _ready() -> void:
	stamp_button.button_down.connect(click_stamp)
	stamp_button.pressed.connect(select_stamp)


func init(stamp_id: String):
	if stamp_id in StampManager._stamp_lookup:
		id = stamp_id
		stamp_button.texture_normal = StampManager.get_stamp_texture(stamp_id)


func click_stamp():
	if id:
		emit_signal("stamp_clicked", {"id": id})


func select_stamp():
	if id:
		emit_signal("stamp_selected", {"id": id})


func _process(_delta: float) -> void:
	custom_minimum_size = Vector2(stamp_size * 1.25, stamp_size * 1.25)
	stamp_button.size = Vector2(stamp_size, stamp_size)
	stamp_button.pivot_offset = Vector2(stamp_button.size.x / 2, stamp_button.size.y / 2)
	size = Vector2(stamp_size * 1.25, stamp_size * 1.25)
	stamp_button.position = Vector2((size.x - stamp_button.size.x) / 2, (size.y - stamp_button.size.y) / 2)
	if stamp_button.visible and stamp_button.is_hovered():
		if stamp_button.is_pressed():
			stamp_button.scale = Vector2(1, 1)
			stamp_button.self_modulate = Color(0.75, 0.75, 0.75)
		else:
			stamp_button.scale = Vector2(1.25, 1.25)
			stamp_button.self_modulate = Color(1.25, 1.25, 1.25)
	else:
		stamp_button.scale = Vector2(1, 1)
		stamp_button.self_modulate = Color(1, 1, 1)
