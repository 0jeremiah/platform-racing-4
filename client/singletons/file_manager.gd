extends Node
## Manages file operations for the game, such as saving and loading levels.

var save_dir: String = "user://editor"
var level_folder_dir: String = "/levels"
var block_folder_dir: String = "/blocks"
var current_level_folder: String = "level1"
var current_level_name: String = "first"
var current_level_description: String = ""
var current_block_name: String = "first"
var current_block_description: String = ""


func _ready() -> void:
	var editor_folder_is_outdated: bool = false
	var filenames := []
	var dir := DirAccess.open(save_dir)
	if dir and dir.dir_exists(save_dir):
		if !dir.dir_exists(save_dir + level_folder_dir):
			filenames = DirAccess.get_files_at(save_dir)
			if !filenames.is_empty():
				for file in filenames.size():
					if filenames[file] == "":
						break
					if filenames[file].ends_with(".json"):
						editor_folder_is_outdated = true
	if editor_folder_is_outdated:
		update_editor_folder()


func get_current_level_data() -> Dictionary:
	if !current_level_folder:
		return {}
	
	var level_dir = get_current_level_dir()
	if not FileAccess.file_exists(level_dir):
		return {}

	var file := FileAccess.open(level_dir, FileAccess.READ)
	var level: Dictionary = JSON.parse_string(file.get_as_text())
	return level


func get_current_level_name_and_description() -> Dictionary:
	var level_dir = get_current_level_dir()
	if not FileAccess.file_exists(level_dir):
		return {"title": "", "description": ""}

	var file := FileAccess.open(level_dir, FileAccess.READ)
	var level: Dictionary = JSON.parse_string(file.get_as_text())
	var title = level.get("title", "")
	var description = level.get("description", "")
	file.close()
	return {"title": title, "description": description}


func get_current_level_folder() -> String:
	return current_level_folder


func get_current_level_description() -> String:
	return current_level_description


func get_current_level_dir() -> String:
	return save_dir + level_folder_dir + "/" + current_level_folder + "/level.json"


func get_level_folder_name(level_folder: String) -> String:
	return "/" + level_folder


# only used for converting old levels without level folders
func get_level_file_name(level_name: String) -> String:
	return "/" + level_name + ".json"


func list_saved_levels() -> Array:
	var filenames := []
	var dir := DirAccess.open(save_dir + level_folder_dir)
	if dir and dir.dir_exists(save_dir + level_folder_dir):
		var level_folder_names = DirAccess.get_directories_at(save_dir + level_folder_dir)
		for level_folder_name in level_folder_names:
			var level_folder = save_dir + level_folder_dir + "/" + level_folder_name
			if not dir.dir_exists(level_folder):
				break
			var level_file = level_folder + "/level.json"
			if FileAccess.file_exists(level_file):
				var file := FileAccess.open(level_file, FileAccess.READ)
				var level: Dictionary = JSON.parse_string(file.get_as_text())
				var title = level.get("title", "")
				if title == "":
					title = level_folder_name
				var description = level.get("description", "")
				filenames.append({"folder": level_folder_name, "title": title, "description": description})
	return filenames
	

func set_current_level_folder(level_folder: String) -> void:
	current_level_folder = level_folder


func set_current_level_name(level_name: String) -> void:
	current_level_name = level_name


func set_current_level_description(level_description: String) -> void:
	current_level_description = level_description


func find_name_for_level_folder() -> String:
	var level_name = "level"
	var level_count = 1
	var level_directory = save_dir + level_folder_dir
	var filenames := []
	var dir := DirAccess.open(level_directory)
	if dir and dir.dir_exists(level_directory):
		filenames = DirAccess.get_files_at(level_directory)
		level_count = filenames.size()
		if dir.file_exists(level_directory + get_level_file_name(level_name + str(level_count))):
			while dir.file_exists(level_directory + get_level_file_name(level_name + str(level_count))):
				level_count += 1
		return level_name + str(level_count)
	return ""
	


func save_level_to_file(level: Dictionary, level_name: String, level_description: String) -> String:
	if level_name == "":
		return ""

	# ensure level directory exists
	if not DirAccess.dir_exists_absolute(save_dir + level_folder_dir):
		DirAccess.make_dir_absolute(save_dir + level_folder_dir)

	# try to find a name for the level folder
	var level_list = list_saved_levels()
	var possible_level_folder = ""
	for level_info in level_list:
		if level_info.title == level_name:
			possible_level_folder = level_info.folder
			break
	if !possible_level_folder:
		possible_level_folder = find_name_for_level_folder()

	# save level to disk if we have a level folder name
	if possible_level_folder:
		var save_file_path: String = save_dir + level_folder_dir + get_level_folder_name(possible_level_folder)
		var level_path: String = save_file_path + "/level.json"
		var blocks_path: String = save_file_path + "/blocks"
		var stamps_path: String = save_file_path + "/stamps"
		var file := FileAccess.open(level_path, FileAccess.WRITE)
		# TODO: make folders for any needed blocks and stamps
		if not DirAccess.dir_exists_absolute(blocks_path):
			DirAccess.make_dir_absolute(blocks_path)
		if not DirAccess.dir_exists_absolute(stamps_path):
			DirAccess.make_dir_absolute(stamps_path)
		var json_string := JSON.stringify(level)
		var encoded_data := Marshalls.utf8_to_base64(json_string)

		file.store_string(json_string)
		file.close()
		
		current_level_folder = possible_level_folder
		current_level_name = level_name
		current_level_description = level_description
		
		return encoded_data
	return ""


func delete_level(level_name: String = current_level_name) -> void:
	var file_name := get_level_file_name(level_name)
	var save_file_path: String = save_dir + level_folder_dir + file_name
	DirAccess.remove_absolute(save_file_path)


func load_level_from_folder(level_folder: String = current_level_folder) -> Dictionary:
	var save_file_path: String = get_current_level_dir()
	if not FileAccess.file_exists(save_file_path):
		return {}

	var file := FileAccess.open(save_file_path, FileAccess.READ)
	var level: Dictionary = JSON.parse_string(file.get_as_text())
	file.close()
	
	return level


func load_block_in_level_folder(level_name: String, block_id: String) -> Dictionary:
	var folder_name := get_level_file_name(level_name)
	var save_file_path: String = save_dir + level_folder_dir + folder_name + "/blocks/" + block_id 
	if not FileAccess.file_exists(save_file_path):
		return {}

	var file := FileAccess.open(save_file_path, FileAccess.READ)
	var block: Dictionary = JSON.parse_string(file.get_as_text())
	file.close()
	
	return block


func update_editor_folder():
	var filenames := []
	var dir := DirAccess.open(save_dir)
	if dir and dir.dir_exists(save_dir):
		filenames = DirAccess.get_files_at(save_dir)
		if !filenames.is_empty():
			if not DirAccess.dir_exists_absolute(save_dir + level_folder_dir):
				DirAccess.make_dir_absolute(save_dir + level_folder_dir)
			for file in filenames.size():
				if filenames[file] == "":
					break
				if filenames[file].ends_with(".json"):
					#var compat_level_name = filenames[file].get_basename().remove_chars("<>:/|?*.!").replace(" ", "_").substr(0, 25)
					var level_folder = "level" + str(file + 1)
					var save_level_folder_dir = save_dir + level_folder_dir + get_level_folder_name(level_folder)
					dir.make_dir(save_level_folder_dir)
					dir.rename(save_dir + "/" + filenames[file], save_level_folder_dir + "/temp_level.json")
					var level_file = FileAccess.open(save_level_folder_dir + "/temp_level.json", FileAccess.READ)
					var level: Dictionary = JSON.parse_string(level_file.get_as_text())
					level_file.close()
					var title = filenames[file].get_basename()
					if level.has("title"):
						title = level.title
					level["title"] = str(title)
					var json_string := JSON.stringify(level)
					var renamed_level_file = FileAccess.open(save_level_folder_dir + "/level.json", FileAccess.WRITE_READ)
					renamed_level_file.store_string(json_string)
					renamed_level_file.close()
					dir.remove(save_level_folder_dir + "/temp_level.json")
					dir.make_dir(save_level_folder_dir + "/blocks")
					dir.make_dir(save_level_folder_dir + "/stamps")
