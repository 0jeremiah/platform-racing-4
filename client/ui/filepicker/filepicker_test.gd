extends Node2D

@onready var file_picker_popup = preload("res://ui/filepicker/filepicker_popup.gd")


func _ready() -> void:
	PopupManager.add_custom_popup(file_picker_popup, {"mode": "load_file", "extensions_list": ["txt"], "title": "-- Import --"})
