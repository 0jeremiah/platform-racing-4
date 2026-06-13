extends Button

signal folder_clicked
signal file_clicked

var folder_icon = preload("res://ui/filepicker/folder_icon.png")
var file_icon = preload("res://ui/filepicker/file_icon.png")
var directory: String = ""
var type: String = "file"


func _ready() -> void:
	pressed.connect(_on_click)


func init(new_directory: String, new_file_name: String, new_type: String):
	directory = new_directory
	if new_type == "folder":
		type = "folder"
		icon = folder_icon
	elif new_type == "file":
		type = "file"
		icon = file_icon
	text = new_file_name


func _on_click():
	if type == "folder":
		emit_signal("folder_clicked", directory)
	elif type == "file":
		emit_signal("file_clicked", directory)
