extends Node2D
class_name LevelEditor

static var editor_cursors: Node
static var current_level: Dictionary
static var current_level_folder: String
static var current_level_name: String
static var current_level_description: String
static var level_editor: Node

@onready var load_popup = preload("res://pages/editor/load_popup.gd")
@onready var save_popup = preload("res://pages/editor/save_popup.gd")
@onready var level_manager: LevelManager = $LevelManager
@onready var game_client = get_node("/root/Main/GameClient")
@onready var http_request = $HTTPRequest
@onready var editor_camera: Camera2D = $EditorCamera

@onready var object_box = $UI/ObjectBoxUI/ObjectBox
@onready var cursor = $UI/Cursor
@onready var camera_controls = $UI/CameraControls
@onready var penciler: Node2D = $Penciler
@onready var bg: Node2D = $BG
@onready var editor_events: EditorEvents = $EditorEvents
@onready var editor_menu: Node2D = $UI/EditorMenu

var default_level: Dictionary = {
	"title": "first",
	"comment": "",
	"map_layers": [{
		"name": "Layer 1",
		"chunks": [],
		"tile_map_rotation": 0.0,
		"z_axis": 10,
		"anchor": {"x": 0.0, "y": 0.0}
	}],
	"art_layers": [{
		"name": "Layer 1",
		"lines": [],
		"stamps": [],
		"texts": [],
		"rotation": 0.0,
		"z_axis": 10,
		"depth": 10,
		"alpha": 100,
		"anchor": {"x": 0.0, "y": 0.0}
	}],
	"properties": {
		"background_id": "pr2_field",
		"fade_color": "FFFFFF",
		"music": "random",
		"level_type": "race",
		"time": 120,
		"gravity": 1.0,
		"password": "",
		"sfchm_chance": 0,
		"wind_chance": 0,
		"snow_chance": 0,
		"alien_chance": 0
		}
}


func _ready():
	LevelEditor.level_editor = self
	editor_menu.set_editor_mode(self)
	tree_exiting.connect(_on_disconnect_editor)
	Jukebox.stop_song(false)
	game_client.connect("request_editor_load", _on_request_editor_load)

	LevelEditor.editor_cursors = get_node("EditorCursorLayer/EditorCursors") # todo: can this be joined with UI/Cursor?
	LevelEditor.editor_cursors.init(level_manager.level_layers)
	
	editor_events.connect_to([cursor, editor_menu, level_manager.level_decoder])
	editor_events.set_game_client(game_client)
	penciler.init(level_manager.level_layers, editor_events)
	
	cursor.init(editor_menu, level_manager.level_layers)
	editor_menu.init(level_manager.level_layers, editor_events)
	editor_menu.cursor_is_enabled.connect(_on_cursor_is_enabled.bind())
	
	camera_controls.init(editor_camera)
	
	editor_menu.control_event.connect(_on_control_event)
	
	var level = {}
	if LevelEditor.current_level:
		level = LevelEditor.current_level
		_load_level(LevelEditor.current_level)
	else:
		var saved_level = FileManager.load_level_from_folder()
		if saved_level:
			level = saved_level
			_load_level(saved_level)
		else:
			level = default_level
			_load_level(default_level)
	
	bg.set_bg(level_manager.background_id, level_manager.fade_color)
	
	var general_settings: Dictionary = {
		"music": level.properties.get("music", "random"),
		"level_type": level.properties.get("level_type", "race"),
		"time": level.properties.get("time", 120),
		"gravity": level.properties.get("gravity", 1.0),
		"password": level.properties.get("password", ""),
		"sfchm_chance": level.properties.get("sfchm_chance", 0),
		"wind_chance": level.properties.get("wind_chance", 0),
		"snow_chance": level.properties.get("snow_chance", 0),
		"alien_chance": level.properties.get("alien_chance", 0)
	}
	
	var level_settings_submenu = editor_menu.level_options_menu.level_settings_submenu
	level_settings_submenu.set_general_settings(general_settings)
	level_settings_submenu.set_item_settings(level_manager.items)


func _load_level(level_data: Dictionary):
	editor_menu.disable_editing()
	editor_camera.position = Vector2(0.0, 0.0)
	level_manager.decode_level(level_data)
	editor_menu.enable_editing()
	level_manager.level_layers._layers_loaded()


func init(data: Dictionary = {}):
	_on_connect_editor()
	if data.has("saved_camera_position"):
		editor_camera.position = data.saved_camera_position


func _on_undo_pressed():
	pass


func _on_redo_pressed():
	pass


func _on_clear_pressed():
	PopupManager.add_confirm_popup(Callable(self, "_on_confirm_clear"), "WARNING!\n\nDeleting things is like burning paper; once the paper has been burnt, the paper is gone FOREVER.\n\nAre you sure you want to do this?")


func _on_load_pressed():
	PopupManager.add_custom_popup(load_popup, {"mode": "level", "load_func": Callable(self, "_on_level_load")})


func _on_save_pressed():
	LevelEditor.current_level = level_manager.encode_level()
	PopupManager.add_custom_popup(save_popup, {"mode": "level", "current_data": LevelEditor.current_level})


func _on_import_pressed():
	pass


func _on_export_pressed():
	pass


func _on_block_editor_pressed():
	LevelEditor.current_level = level_manager.encode_level()
	#FileManager.save_level_to_file(LevelEditor.current_level, current_level_name)
	await Main.set_scene(Main.BLOCK_EDITOR)


func _on_back_pressed():
	LevelEditor.current_level = level_manager.encode_level()
	#FileManager.save_level_to_file(LevelEditor.current_level, current_level_name)
	await Main.set_scene(Main.TITLE)


func _on_test_pressed():
	LevelEditor.current_level = level_manager.encode_level()
	#FileManager.save_level_to_file(LevelEditor.current_level, current_level_name)
	Main.set_scene(Main.TESTER, {"level": LevelEditor.current_level})


func _on_confirm_clear():
	_on_level_load("", "", "")


func _on_level_load(level_folder = current_level_folder, level_name = "", level_description = ""):
	editor_menu.disable_editing()
	FileManager.set_current_level_folder(level_folder)
	FileManager.set_current_level_name(level_name)
	FileManager.set_current_level_description(level_description)
	
	var selected_level = default_level
	if (level_folder != ""):
		selected_level = FileManager.load_level_from_folder(level_folder)
	
	level_manager.clear()
	LevelEditor.current_level = selected_level
	await get_tree().create_timer(0.1).timeout
	_load_level(selected_level)
	editor_menu.enable_editing()


func _on_request_editor_load():
	editor_menu.disable_editing()
	FileManager.set_current_level_folder("")
	FileManager.set_current_level_name("")
	FileManager.set_current_level_description("")
	level_manager.clear()
	await get_tree().create_timer(0.1).timeout
	_load_level(LevelEditor.current_level)
	editor_menu.enable_editing()


func _on_control_event(event: Dictionary) -> void:
	if event.get("type") == "editor_camera_zoom_change":
		var zoom_value = event.get("zoom")
		if zoom_value:
			editor_camera.change_camera_zoom(zoom_value)
	elif event.get("type") == "set_background":
		level_manager.background_id = event.get("bg", "pr2_field")
		level_manager.fade_color = event.get("fade_color", "FFFFFF")
		bg.set_bg(level_manager.background_id, level_manager.fade_color)
	elif event.get("type") == "set_music":
		level_manager.music = event.get("music", "random")
	elif event.get("type") == "set_level_type":
		level_manager.level_type = event.get("level_type", "race")
	elif event.get("type") == "set_time":
		level_manager.time = event.get("time", 120)
	elif event.get("type") == "set_gravity":
		level_manager.gravity = event.get("gravity", 1.0)
	elif event.get("type") == "set_password":
		level_manager.password = event.get("password", "")
	elif event.get("type") == "set_sfchm_chance":
		level_manager.sfchm_chance = event.get("sfchm_chance", 0)
	elif event.get("type") == "set_wind_chance":
		level_manager.wind_chance = event.get("wind_chance", 0)
	elif event.get("type") == "set_snow_chance":
		level_manager.snow_chance = event.get("snow_chance", 0)
	elif event.get("type") == "set_alien_chance":
		level_manager.alien_chance = event.get("alien_chance", 0)
	elif event.get("type") == "set_items":
		level_manager.items = event.get("items", Items.get_default_item_ids())
	


func _on_connect_editor() -> void:
	$EditorEvents.connect("send_editor_event", game_client._on_send_editor_event)


func _on_disconnect_editor() -> void:
	if $EditorEvents:
		$EditorEvents.disconnect("send_editor_event", game_client._on_send_editor_event)
	
	LevelEditor.editor_cursors = null
	
	if Session.is_logged_in() and !game_client.isFirstOpenEditor:
		var data_room = {
			"module": "RequestRoomModule",
			"id": "dummy_username", # this doesn't work -> Session.get_username()
			"ms": 5938,
			"room" : game_client.room,
			"ret": true,
		}
		game_client.send_queue.push_back(data_room)
	
	game_client.isFirstOpenEditor = false
	if LevelEditor.editor_cursors:
		LevelEditor.editor_cursors.add_new_cursor(Session.get_username())
	game_client.toggle_editor_buttons(game_client.is_live_editing)


func _on_cursor_is_enabled(new_bool: bool) -> void:
	if new_bool:
		cursor.activate()
	else:
		cursor.deactivate()
