extends Control

@onready var folder_icon = $FolderIcon
@onready var program_icon = $ProgramIcon
@onready var file_name = $FileName
@onready var file_button = $FileButton

var directory_name: String = ""


func _ready() -> void:
	pass


func init(new_file_name: String):
	file_name.text = new_file_name
	directory_name = new_file_name
