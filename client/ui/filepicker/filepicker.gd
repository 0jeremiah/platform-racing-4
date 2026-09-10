extends Control

signal folder_chosen
signal file_chosen

@onready var file_row = preload("res://ui/filepicker/filerow.tscn")
@onready var file_picker_label = $FilePickerLabel
@onready var back_button = $BackButton
@onready var forward_button = $ForwardButton
@onready var recent_locations_button = $RecentLocationsButton
@onready var up_button = $UpButton
@onready var refresh_button = $RefreshButton
@onready var files_and_folders_container = $FilesList/FilesAndFoldersContainer
@onready var files_and_folders = $FilesList/FilesAndFoldersContainer/FilesAndFolders
@onready var desktop_button = $Libraries/DirectoriesContainer/Directories/NormalDirectories/DesktopButton
@onready var documents_button = $Libraries/DirectoriesContainer/Directories/NormalDirectories/DocumentsButton
@onready var downloads_button = $Libraries/DirectoriesContainer/Directories/NormalDirectories/DownloadsButton
@onready var music_button = $Libraries/DirectoriesContainer/Directories/NormalDirectories/MusicButton
@onready var pictures_button = $Libraries/DirectoriesContainer/Directories/NormalDirectories/PicturesButton
@onready var videos_button = $Libraries/DirectoriesContainer/Directories/NormalDirectories/VideosButton
@onready var drivers_directories = $Libraries/DirectoriesContainer/Directories/DriversDirectories
@onready var directory_bar = $DirectoryBar
@onready var destination_bar = $DestinationBar
@onready var recent_locations_popup = $RecentLocationsPopup

var folder_icon = preload("res://ui/filepicker/folder_icon.png")
var file_icon = preload("res://ui/filepicker/file_icon.png")
var dir_access = DirAccess
var type: String = "load"
var current_dir = ""
var maybe_new_dir = ""
var dir_history: Array = []
var dir_page: int = 0
var include_files: bool = false
var limit_to_extensions: bool = true
var allowed_extensions: Array = ["json"]
var double_click_interval: float = 0.5
var double_click_timer: float = 0.0
var double_click: bool = false
var selected_dir: String = ""


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
	recent_locations_button.pressed.connect(_recent_locations)
	refresh_button.pressed.connect(_refresh)
	desktop_button.pressed.connect(change_directory.bind(OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP)))
	documents_button.pressed.connect(change_directory.bind(OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)))
	downloads_button.pressed.connect(change_directory.bind(OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS)))
	music_button.pressed.connect(change_directory.bind(OS.get_system_dir(OS.SYSTEM_DIR_MUSIC)))
	pictures_button.pressed.connect(change_directory.bind(OS.get_system_dir(OS.SYSTEM_DIR_PICTURES)))
	videos_button.pressed.connect(change_directory.bind(OS.get_system_dir(OS.SYSTEM_DIR_MOVIES)))
	directory_bar.text_submitted.connect(change_directory.bind())
	destination_bar.text_submitted.connect(_check_destination.bind())
	recent_locations_popup.set_dropdown_size(Vector2(920.0, 676.0))
	recent_locations_popup.return_dropdown_data.connect(_set_dir_page.bind())


func _process(delta: float) -> void:
	if double_click_timer - delta > 0.0:
		double_click_timer -= delta
	elif double_click or double_click_timer > 0.0:
		double_click_timer = 0.0
		double_click = false


func init(look_for: String, extensions_list: Array = [], new_current_dir: String = ""):
	if look_for == "folder":
		include_files = false
		limit_to_extensions = false
		if new_current_dir != "" and dir_access.dir_exists(new_current_dir):
			current_dir = new_current_dir
		else:
			current_dir = OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS)
		update_list(current_dir)
	elif look_for == "file":
		include_files = true
		if !extensions_list.is_empty():
			limit_to_extensions = true
			allowed_extensions = extensions_list
		else:
			limit_to_extensions = false
		if new_current_dir != "" and dir_access.dir_exists(new_current_dir):
			current_dir = new_current_dir
		else:
			current_dir = OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS)
		update_list(current_dir)


func update_list(dir_location: String):
	back_button.disabled = true
	forward_button.disabled = true
	recent_locations_button.disabled = true
	up_button.disabled = true
	for child in files_and_folders.get_children():
		child.queue_free()
	files_and_folders_container.scroll_horizontal = 0
	files_and_folders_container.scroll_vertical = 0
	var folders = DirAccess.get_directories_at(dir_location)
	for folder in folders:
		var file_node = file_row.instantiate()
		files_and_folders.add_child(file_node)
		file_node.init(current_dir + "/" + folder, folder, "folder")
		file_node.folder_clicked.connect(folder_select.bind())
	if include_files:
		var files = DirAccess.get_files_at(dir_location)
		for file in files:
			if !limit_to_extensions or (limit_to_extensions and file.get_extension() in allowed_extensions):
				var file_node = file_row.instantiate()
				files_and_folders.add_child(file_node)
				file_node.init(current_dir + "/" + file, file, "file")
				file_node.file_clicked.connect(file_select.bind())
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


func folder_select(new_path: String):
	if !include_files and dir_access.dir_exists(new_path):
		selected_dir = new_path
		maybe_update_destination_bar(new_path)
	if maybe_new_dir == new_path and double_click:
		change_directory(new_path)
		double_click_timer = 0.0
		double_click = false
		maybe_new_dir = ""
	else:
		double_click_timer = double_click_interval
		double_click = true
		maybe_new_dir = new_path


func file_select(new_path: String):
	if include_files and dir_access.file_exists(new_path):
		selected_dir = new_path
		maybe_update_destination_bar(new_path)
		if maybe_new_dir == new_path and double_click:
			emit_signal("file_chosen", new_path)
			double_click_timer = 0.0
			double_click = false
			maybe_new_dir = ""
		else:
			double_click_timer = double_click_interval
			double_click = true
			maybe_new_dir = new_path


func update_history(new_dir: String):
	if dir_history.size() - 1 > dir_page:
		dir_history = dir_history.slice(0, dir_page + 1)
	dir_history.append(new_dir)
	dir_page = dir_history.size() - 1


func maybe_update_destination_bar(new_dir: String):
	if !include_files and dir_access.dir_exists(new_dir):
		destination_bar.text = new_dir.get_slice("/", new_dir.get_slice_count("/") - 1)
	if include_files and dir_access.file_exists(new_dir):
		destination_bar.text = new_dir.get_file()


func _check_destination(new_dir: String):
	if !include_files:
		if dir_access.dir_exists(get_current_dir() + new_dir) or current_dir == selected_dir:
			if current_dir == selected_dir:
				emit_signal("folder_chosen", get_current_dir() + new_dir)
			else:
				change_directory(get_current_dir() + new_dir)
		else:
			error_popup(1, get_current_dir() + new_dir)
	if include_files:
		if dir_access.file_exists(get_current_dir() + new_dir):
			emit_signal("file_chosen", get_current_dir() + new_dir)
		else:
			error_popup(2, get_current_dir() + new_dir)


func change_directory(new_path: String):
	if dir_access.dir_exists(new_path):
		selected_dir = new_path
		maybe_update_destination_bar(new_path)
		if new_path != current_dir:
			update_history(new_path)
		current_dir = new_path
		update_list(current_dir)
	else:
		directory_bar.text = current_dir
		error_popup(0, new_path)


func _back():
	if dir_page > 0:
		if dir_access.dir_exists(dir_history[dir_page - 1]):
			dir_page -= 1
			current_dir = dir_history[dir_page]
			maybe_update_destination_bar(current_dir)
			update_list(current_dir)
		else:
			error_popup(0, dir_history[dir_page - 1])


func _forward():
	if dir_page < dir_history.size() - 1:
		if dir_access.dir_exists(dir_history[dir_page + 1]):
			dir_page += 1
			current_dir = dir_history[dir_page]
			maybe_update_destination_bar(current_dir)
			update_list(current_dir)
		else:
			error_popup(0, dir_history[dir_page + 1])


func _recent_locations():
	var recent_locations = []
	if dir_history.size() > 10:
		var min_locations = 0
		var max_locations = dir_history.size() - 1
		if dir_page - 10 > 0:
			min_locations = dir_page - 10
		if dir_page + 10 < dir_history.size() - 1:
			max_locations = dir_page + 10
		recent_locations = dir_history.slice(min_locations, max_locations)
	else:
		recent_locations = dir_history
	if recent_locations.size() > 0:
		recent_locations_popup.clear()
		for recent_location in recent_locations.size():
			recent_locations_popup.add_option(recent_locations[recent_location], (dir_history.size() - recent_locations.size()) + recent_location)
		recent_locations_popup.show_popup(recent_locations_button.global_position.x, recent_locations_button.global_position.y + recent_locations_button.size.y)


func _set_dir_page(new_dir_page: int):
	if new_dir_page >= 0 and new_dir_page <= dir_history.size() - 1:
		if dir_access.dir_exists(dir_history[new_dir_page]):
			dir_page = new_dir_page
			current_dir = dir_history[dir_page]
			maybe_update_destination_bar(current_dir)
			update_list(current_dir)
	else:
		error_popup(3)


func _up():
	var new_dir_array = current_dir.split("/", false, 0)
	if new_dir_array.size() > 1:
		new_dir_array.remove_at(new_dir_array.size() - 1)
		var new_dir = "/".join(new_dir_array)
		if dir_access.dir_exists(new_dir):
			change_directory(new_dir)
		else:
			error_popup(0, new_dir)


func _refresh():
	if dir_access.dir_exists(current_dir):
		update_list(current_dir)
	else:
		error_popup(0, current_dir)


func get_destination_bar_text() -> String:
	return destination_bar.text


func error_popup(error_type: int = 0, params: String = ""):
	match error_type:
		0: PopupManager.add_message_popup("The following directory is either missing, hidden, or otherwise not available:\n" + params)
		1: PopupManager.add_message_popup("This directory is either not a valid folder path or just can't be written to:\n" + params)
		2: PopupManager.add_message_popup("This file either no longer exists or cannot be written to:\n" + params)
		3: PopupManager.add_message_popup("Page number was indexed out of dir_history's bounds.")
		_: PopupManager.add_message_popup("Unspecified error:\n" + params)
