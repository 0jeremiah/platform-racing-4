extends Popup

signal name_change

@onready var new_layer_name = $NewLayerName
@onready var ok_button = $OKButton


func _ready() -> void:
	ok_button.pressed.connect(_set_new_name)
	self.popup_hide.connect(_set_new_name)


func _set_new_name():
	if visible and !new_layer_name.text.is_empty():
		emit_signal("name_change", new_layer_name.text)
