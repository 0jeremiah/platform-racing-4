extends Control

signal stamp_mode_changed

@onready var mode_text = $ModeText
@onready var stamp_mode_button = $StampModeButton
@onready var stamp_mode_popup = $StampModePopup
@onready var stamp_mode_tab = $StampModePopup/StampMode/StampModeTab
var spawn_x: float
var spawn_y: float


func _ready() -> void:
	stamp_mode_button.pressed.connect(_show_popup)
	stamp_mode_tab.tab_changed.connect(_set_stamp_mode)


func _show_popup(_spawn_x: float = spawn_x, _spawn_y: float = spawn_y):
	stamp_mode_popup.popup(Rect2i(global_position.x + _spawn_x, global_position.y + _spawn_y, 500, 312))


func _set_stamp_mode(new_index: int):
	if new_index == 1:
		mode_text.text = "Stmp."
		emit_signal("stamp_mode_changed", "stamp")
	else:
		mode_text.text = "Stckr."
		emit_signal("stamp_mode_changed", "sticker")
	stamp_mode_popup.hide()
