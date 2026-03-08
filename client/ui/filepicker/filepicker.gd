extends Control

@onready var file_row = preload("res://ui/filepicker/filerow.tscn")
@onready var dir_label = $DirLabel
@onready var back_button = $BackButton
@onready var file_container = $ScrollContainer/VBoxContainer

var current_dir = "res://"
var dir_list: PackedStringArray = []
var dir_access = DirAccess


func _ready() -> void:
	dir_access = DirAccess.open("res://")
	var current_drive = dir_access.get_current_drive()
	var current_drive_name = DirAccess.get_drive_name(current_drive)
	dir_access = DirAccess.open(current_drive_name)
	dir_access.include_navigational = true
	dir_access.get_current_dir()
	dir_list = DirAccess.get_directories_at(dir_access.get_current_dir(true))
	print(dir_access.get_current_dir(true))
	print(dir_list)
	change_directory(current_dir)
	back_button.pressed.connect(_back)


func update_list():
	for child in file_container.get_children():
		child.free()
	for dir in dir_list:
		var file_node = file_row.instantiate()
		file_container.add_child(file_node)
		file_node.init(dir)
		file_node.file_button.pressed.connect(_maybe_change_directory.bind(file_node.directory_name))


func _back():
	if current_dir != "res://":
		var new_dir_array = current_dir.trim_prefix("res://").split("/", false, 0)
		new_dir_array.remove_at(new_dir_array.size() - 1)
		var new_dir = ""
		if new_dir_array.size() > 0:
			new_dir = "res://" + "/".join(new_dir_array) + "/"
		else:
			new_dir = "res://"
		if dir_access.dir_exists(new_dir):
			change_directory(new_dir)


func _maybe_change_directory(new_directory: String):
	var maybe_new_directory = current_dir + new_directory + "/"
	if dir_access.dir_exists(maybe_new_directory):
		change_directory(maybe_new_directory)


func change_directory(new_path: String):
	current_dir = new_path
	dir_list = DirAccess.get_directories_at(current_dir)
	update_list()
	dir_label.text = current_dir
	if current_dir != "res://":
		back_button.disabled = false
	else:
		back_button.disabled = true
