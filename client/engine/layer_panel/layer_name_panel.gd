extends Control

signal set_layer_name

@onready var color_rect = $ColorRect
@onready var layer_name_box = $LayerNameBox
@onready var ok_button = $OKButton

var sent_new_layer_name: bool = false


func _ready() -> void:
	ok_button.pressed.connect(_change_layer_name)


func set_rename_layer_panel_size(new_size: Vector2):
	size = Vector2(max(new_size.x, 160.0), max(new_size.y, 40.0))
	color_rect.size = size
	layer_name_box.size = Vector2(size.x - 60, size.y)
	ok_button.position = Vector2(layer_name_box.size.x + 10, 0.0)


func set_layer_name_string(new_layer_name: String):
	layer_name_box.text = new_layer_name


func _change_layer_name():
	emit_signal("set_layer_name", layer_name_box.text)
	sent_new_layer_name = true


func _exit_tree() -> void:
	if !sent_new_layer_name:
		_change_layer_name()
