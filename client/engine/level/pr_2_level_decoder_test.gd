extends Node2D

@onready var import_button = $Button
@onready var pr2_level_decoder = $PR2LevelDecoder
var file_picker_popup = preload("res://ui/filepicker/filepicker_popup.gd")
var level_data = null


func _ready() -> void:
	import_button.pressed.connect(_import_pr2_level_pressed)


func _import_pr2_level_pressed():
	PopupManager.add_custom_popup(file_picker_popup, {"mode": "load_file", "load_func": Callable(self, "_load_pr2_level"), "extensions_list": ["txt"], "title": "-- Import PR2 Level --"})


func _load_pr2_level(pr2_level_dir: String):
	if FileAccess.file_exists(pr2_level_dir):
		var pr2_level = FileAccess.open(pr2_level_dir, FileAccess.READ)
		var pr2_level_data = pr2_level.get_as_text()
		pr2_level.close()
		level_data = pr2_level_decoder.decode_pr2_level(pr2_level_data)
