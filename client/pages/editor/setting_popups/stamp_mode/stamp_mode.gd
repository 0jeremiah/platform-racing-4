extends Control

signal stamp_mode_changed

@onready var stamp_mode_tab = $StampModeTab


func _ready() -> void:
	stamp_mode_tab.tab_clicked.connect(_set_stamp_mode)


func _set_stamp_mode_tab(new_stamp_mode: String):
	if new_stamp_mode == "sticker":
		stamp_mode_tab.current_tab = 0
	elif new_stamp_mode == "stamp":
		stamp_mode_tab.current_tab = 1


func _set_stamp_mode(new_index: int):
	var stamp_mode: String
	if new_index == 1:
		stamp_mode = "stamp"
	else:
		stamp_mode = "sticker"
	emit_signal("stamp_mode_changed", stamp_mode)
