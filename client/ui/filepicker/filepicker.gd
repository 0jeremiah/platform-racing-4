extends Control

@onready var file_row = preload("res://ui/filepicker/filerow.tscn")
@onready var back_button = $BackButton
@onready var forward_button = $ForwardButton
@onready var recent_locations_button = $RecentLocationsButton
@onready var up_button = $UpButton
@onready var directory_bar = $DirectoryBar
@onready var file_container = $ScrollContainer/VBoxContainer
@onready var desktop_button = $Libraries/DirectoriesContainer/Directories/NormalDirectories/DesktopButton
@onready var documents_button = $Libraries/DirectoriesContainer/Directories/NormalDirectories/DocumentsButton
@onready var downloads_button = $Libraries/DirectoriesContainer/Directories/NormalDirectories/DownloadsButton
@onready var music_button = $Libraries/DirectoriesContainer/Directories/NormalDirectories/MusicButton
@onready var pictures_button = $Libraries/DirectoriesContainer/Directories/NormalDirectories/PicturesButton
@onready var videos_button = $Libraries/DirectoriesContainer/Directories/NormalDirectories/VideosButton
@onready var drivers_directories = $Libraries/DirectoriesContainer/Directories/DriversDirectories

var folder_icon = preload("res://ui/filepicker/folder_icon.png")
var file_icon = preload("res://ui/filepicker/file_icon.png")
var dir_access = DirAccess
var current_dir = ""
var dir_history: Array = []
var dir_page: int = 0
var include_files: bool = true


func _ready() -> void:
	current_dir = OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS)
	dir_access = DirAccess.open(current_dir)
	dir_access.include_navigational = true
	for driver in dir_access.get_drive_count():
		var driver_name = dir_access.get_drive_name(driver)
		var driver_button = Button.new()
		driver_button.text = driver_name
		driver_button.icon = folder_icon
		driver_button.flat = true
		driver_button.alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_LEFT
		driver_button.clip_text = true
		driver_button.expand_icon = true
		driver_button.custom_minimum_size = Vector2(138.0, 30.0)
		driver_button.set("theme_override_font_sizes/font_size", 16)
		if !dir_access.dir_exists(driver_name):
			driver_button.disabled = true
		drivers_directories.add_child(driver_button)
		driver_button.pressed.connect(change_directory.bind(driver_name))
	update_history(current_dir)
	update_list(current_dir)
	back_button.pressed.connect(_back)
	forward_button.pressed.connect(_forward)
	up_button.pressed.connect(_up)
	desktop_button.pressed.connect(change_directory.bind(OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP)))
	documents_button.pressed.connect(change_directory.bind(OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)))
	downloads_button.pressed.connect(change_directory.bind(OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS)))
	music_button.pressed.connect(change_directory.bind(OS.get_system_dir(OS.SYSTEM_DIR_MUSIC)))
	pictures_button.pressed.connect(change_directory.bind(OS.get_system_dir(OS.SYSTEM_DIR_PICTURES)))
	videos_button.pressed.connect(change_directory.bind(OS.get_system_dir(OS.SYSTEM_DIR_MOVIES)))


func update_list(dir_location: String):
	back_button.disabled = true
	forward_button.disabled = true
	recent_locations_button.disabled = true
	up_button.disabled = true
	for child in file_container.get_children():
		child.queue_free()
	var folders = DirAccess.get_directories_at(dir_location)
	for folder in folders:
		var file_node = file_row.instantiate()
		file_container.add_child(file_node)
		file_node.init(current_dir + "/" + folder, folder, "folder")
		file_node.folder_clicked.connect(change_directory.bind())
	if include_files:
		var files = DirAccess.get_files_at(dir_location)
		for file in files:
			var file_node = file_row.instantiate()
			file_container.add_child(file_node)
			file_node.init(current_dir + "/" + file, file, "file")
			file_node.folder_clicked.connect(change_directory.bind())
	directory_bar.text = current_dir
	var current_dir_array = current_dir.split("/", false, 0)
	if dir_page > 0:
		back_button.disabled = false
	if dir_page < dir_history.size() - 1:
		forward_button.disabled = false
	if dir_history.size() > 1:
		recent_locations_button.disabled = false
	if current_dir_array.size() > 1:
		up_button.disabled = false


func get_current_dir() -> String:
	return current_dir + "/"


func update_history(new_dir: String):
	if dir_history.size() - 1 > dir_page:
		dir_history = dir_history.slice(0, dir_page + 1)
	dir_history.append(new_dir)
	dir_page = dir_history.size() - 1


func change_directory(new_path: String):
	if dir_access.dir_exists(new_path):
		current_dir = new_path
		update_history(current_dir)
		update_list(current_dir)


func _back():
	if dir_page > 0:
		dir_page -= 1
		current_dir = dir_history[dir_page]
		update_list(current_dir)


func _forward():
	if dir_page < dir_history.size() - 1:
		dir_page += 1
		current_dir = dir_history[dir_page]
		update_list(current_dir)


func _up():
	var new_dir_array = current_dir.split("/", false, 0)
	if new_dir_array.size() > 1:
		new_dir_array.remove_at(new_dir_array.size() - 1)
		var new_dir = "/".join(new_dir_array)
		if dir_access.dir_exists(new_dir):
			change_directory(new_dir)
