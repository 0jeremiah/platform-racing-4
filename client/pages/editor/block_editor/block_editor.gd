extends Node2D
class_name BlockEditor

# very much wip. mostly copied over from LevelEditor so if some
#stuff from level editor is there or something is wrong, that
#is why.

static var current_block: Dictionary
static var current_block_name: String
static var current_block_description: String
static var block_editor: Node

@onready var save_popup = preload("res://pages/editor/save_popup.gd")
@onready var block_manager: BlockManager = $SubViewportContainer/SubViewport/BlockManager
#@onready var game_client = get_node("/root/Main/GameClient")
@onready var editor_camera: Camera2D = $EditorCamera
@onready var editor_events: EditorEvents = $EditorEvents
@onready var cursor = $UI/Cursor
@onready var camera_controls = $UI/CameraControls
@onready var penciler: Node2D = $Penciler
@onready var sub_viewport: SubViewport = $SubViewportContainer/SubViewport
@onready var editor_menu: Node2D = $UI/EditorMenu

var default_block: Dictionary = {
	"id": "c-1",
	"settings": {
		"title": "Default Block",
		"description": "Loaded in case no saved blocks are found, nothing is here though.",
		"matter_type": ConfigurableBlockSettings.SOLID,
		"block_type": ConfigurableBlockSettings.ACTIVE,
		"left": {"type": ConfigurableBlockSideSettings.ACTIVE, "params": {}},
		"right": {"type": ConfigurableBlockSideSettings.ACTIVE, "params": {}},
		"top": {"type": ConfigurableBlockSideSettings.ACTIVE, "params": {}},
		"bottom": {"type": ConfigurableBlockSideSettings.ACTIVE, "params": {}},
		"bump": {"type": ConfigurableBlockSideSettings.ACTIVE, "params": {}},
		"stand": {"type": ConfigurableBlockSideSettings.ACTIVE, "params": {}},
		"any_side": {"type": ConfigurableBlockSideSettings.ACTIVE, "params": {}}
	},
	"custom_image": {
		"art_layers": [{
			"name": "Layer 1",
			"lines": [],
			"stamps": [],
			"texts": [],
			"rotation": 0.0,
			"alpha": 100,
			"anchor": {"x": 0.0, "y": 0.0}
		}]
		}
}


func init(data: Dictionary = {}):
	#_on_connect_editor()
	pass


func _ready():
	BlockEditor.block_editor = self
	editor_menu.set_editor_mode(self)
	#tree_exiting.connect(_on_disconnect_editor)
	Jukebox.stop_song(false)
	#game_client.connect("request_editor_load", _on_request_editor_load)

	#BlockEditor.editor_cursors = get_node("EditorCursorLayer/EditorCursors") # todo: can this be joined with UI/Cursor?
	#BlockEditor.editor_cursors.init(block_manager.block_layers)
	
	var penciler: Node2D = get_node("Penciler")
	var editor_events: EditorEvents = get_node("EditorEvents")
	var cursor: Cursor = get_node("UI/Cursor")
	var editor_menu = get_node("UI/EditorMenu")
	#var layer_panel_node = get_node("UI/LayerPanel")
	#var game_client_node = get_node("/root/Main/GameClient")
	
	editor_events.connect_to([cursor, editor_menu, block_manager.block_decoder])
	#editor_events.set_game_client(game_client)
	penciler.init(block_manager.block_layers, editor_events)
	
	cursor.init(editor_menu, block_manager.block_layers)
	editor_menu.init(block_manager.block_layers, editor_events)
	editor_menu.cursor_is_enabled.connect(_on_cursor_is_enabled.bind())
	
	camera_controls.init(editor_camera)
	
	editor_menu.control_event.connect(_on_control_event)
	# now_editing_panel.init($UI/EditorMenu, self)
	
	var block = {}
	if BlockEditor.current_block:
		block = BlockEditor.current_block
		_load_block(BlockEditor.current_block)
	else:
		block = default_block
		_load_block(block)
		pass
		#var saved_block = FileManager.load_from_file()
		#if saved_block:
			#block = saved_block
			#_load_block(saved_block)
		#else:
			#block = default_block
			#_load_block(default_block)


func _load_block(block_data: Dictionary):
	editor_menu.can_edit = false
	block_manager.decode_block(block_data)
	editor_menu.can_edit = true
	block_manager.block_layers._layers_loaded()


func _enable_editing():
	editor_menu.can_edit = true


func _on_back_pressed():
	BlockEditor.current_block = block_manager.encode_block(editor_menu.block_options_menu.block_settings_submenu.block_settings, sub_viewport)
	#FileManager.save_to_file(BlockEditor.current_block, current_block_name)
	await Main.set_scene(Main.TITLE)


func _on_level_editor_pressed():
	BlockEditor.current_block = block_manager.encode_block(editor_menu.block_options_menu.block_settings_submenu.block_settings, sub_viewport)
	#FileManager.save_to_file(BlockEditor.current_block, current_block_name)
	await Main.set_scene(Main.LEVEL_EDITOR)


func _on_save_pressed():
	await RenderingServer.frame_post_draw
	BlockEditor.current_block = block_manager.encode_block(editor_menu.block_options_menu.block_settings_submenu.block_settings, sub_viewport)
	PopupManager.add_custom_popup(save_popup, {"mode": "block", "current_data": BlockEditor.current_block})


func _on_block_load(block_name = "", block_description = ""):
	#FileManager.set_current_block_name(block_name)
	#FileManager.set_current_block_description(block_description)
	
	#var selected_block = default_block
	#if (block_name != ""):
		#selected_block = FileManager.load_from_file(block_name)
	
	#editor_menu.disable_editing()
	#block_manager.clear()
	#BlockEditor.current_block = selected_block
	#await get_tree().create_timer(0.1).timeout
	#_load_block(selected_block)
	pass


func _on_control_event(event: Dictionary) -> void:
	pass


func _on_cursor_is_enabled(new_bool: bool) -> void:
	if new_bool:
		cursor.activate()
	else:
		cursor.deactivate()
	pass
