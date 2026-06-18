extends Control

@onready var play_button = $PlayButton
@onready var text_edit: TextEdit = $TextEdit
@onready var back_button: Button = $BackButton
@onready var import_pr2_level_button: Button = $ImportPR2LevelButton

var file_picker_popup = preload("res://ui/filepicker/filepicker_popup.gd")


func _ready() -> void:
	play_button.pressed.connect(_play_pressed)
	back_button.pressed.connect(_back_pressed)
	import_pr2_level_button.pressed.connect(_import_pr2_level_pressed)


func _back_pressed():
	Main.set_scene(Main.TITLE)


func _play_pressed():
	Game.pr2_level_id = text_edit.text
	Main.set_scene(Main.GAME)


func _import_pr2_level_pressed():
	PopupManager.add_custom_popup(file_picker_popup, {"mode": "load_file", "extensions_list": ["txt"], "title": "-- Import PR2 Level --"})
