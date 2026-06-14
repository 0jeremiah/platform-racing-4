extends ButtonPopup

@onready var file_picker = preload("res://ui/filepicker/filepicker.tscn")

var file_picker_node = null
var load_func = null
var save_func = null


func _ready() -> void:
	super()
	file_picker_node = file_picker.instantiate()
	add_node_to_holder(file_picker_node)
	create_button("Cancel", Callable(self, "_cancel"))


func init(init_params: Dictionary):
	var extensions_list = []
	var current_dir = ""
	if "extensions_list" in init_params:
		extensions_list = init_params.extensions_list
	if "current_dir" in init_params:
		current_dir = init_params.current_dir
	if "load_func" in init_params:
		load_func = init_params.load_func
	if "save_func" in init_params:
		save_func = init_params.save_func
	var mode = ""
	if "mode" in init_params:
		match init_params.mode:
			"load_folder": mode = init_params.mode; clear_buttons(); create_button("Load", Callable(self, "_maybe_load_folder")); file_picker_node.folder_chosen.connect(_maybe_load_folder.bind()); file_picker_node.init("folder", extensions_list, current_dir); create_button("Cancel", Callable(self, "_cancel"))
			"save_folder": mode = init_params.mode; clear_buttons(); create_button("Save", Callable(self, "_maybe_save_folder")); file_picker_node.folder_chosen.connect(_maybe_save_folder.bind()); file_picker_node.init("folder", extensions_list, current_dir); create_button("Cancel", Callable(self, "_cancel"))
			"load_file": mode = init_params.mode; clear_buttons(); create_button("Load", Callable(self, "_maybe_load_file")); file_picker_node.file_chosen.connect(_maybe_load_file.bind()); file_picker_node.init("file", extensions_list, current_dir); create_button("Cancel", Callable(self, "_cancel"))
			"save_file": mode = init_params.mode; clear_buttons(); create_button("Save", Callable(self, "_maybe_save_file")); file_picker_node.file_chosen.connect(_maybe_save_file.bind()); file_picker_node.init("file", extensions_list, current_dir); create_button("Cancel", Callable(self, "_cancel"))
	if "title" in init_params:
		file_picker_node.file_picker_label.text = init_params.title


func _maybe_load_folder(new_dir: String = ""):
	var chosen_dir = ""
	if new_dir != "":
		chosen_dir = new_dir
	else:
		chosen_dir = file_picker_node.selected_dir
	var dir_access = DirAccess.open(chosen_dir)
	if dir_access.dir_exists(chosen_dir):
		if load_func is Callable:
			load_func.call(chosen_dir)
		queue_free()
	else:
		PopupManager.add_message_popup("Cannot load:/n" + chosen_dir + "/nIt's either missing or unreadable.")


func _maybe_save_folder(new_dir: String = ""):
	var chosen_dir = ""
	if new_dir != "":
		chosen_dir = new_dir
	else:
		chosen_dir = file_picker_node.selected_dir
	var dir_access = DirAccess.open(chosen_dir)
	if dir_access.dir_exists(chosen_dir):
		if save_func is Callable:
			save_func.call(chosen_dir)
		queue_free()
	else:
		PopupManager.add_message_popup("Cannot save folder at:/n" + chosen_dir + "/nIt's either missing or unreadable.")


func _maybe_load_file(new_dir: String = ""):
	var chosen_dir = ""
	if new_dir != "":
		chosen_dir = new_dir
	else:
		chosen_dir = file_picker_node.selected_dir
	if FileAccess.file_exists(chosen_dir):
		if load_func is Callable:
			load_func.call(chosen_dir)
		queue_free()
	else:
		PopupManager.add_message_popup("Cannot load:/n" + chosen_dir + "/nIt's either missing or unreadable.")


func _maybe_save_file(new_dir: String = ""):
	var chosen_dir = ""
	if new_dir != "":
		chosen_dir = new_dir
	else:
		chosen_dir = file_picker_node.selected_dir
	if FileAccess.file_exists(chosen_dir):
		if save_func is Callable:
			save_func.call(chosen_dir)
		queue_free()
	else:
		PopupManager.add_message_popup("Cannot save file at:/n" + chosen_dir + "/nIt's either missing or unreadable.")


func _cancel():
	queue_free()
