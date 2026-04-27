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
@onready var editor_menu: Node2D = $UI/EditorMenu

var default_block: Dictionary = {
	"title": "Basic Block 1",
	"description": "Bland, but at least it gets the job done.",
	"settings": {
		"matter_type": ConfigurableBlockSettings.SOLID,
		"block_type": ConfigurableBlockSettings.ACTIVE,
		"health": 100,
		"stat_supply": 1,
		"item_supply": 1,
		"left": {"type": ConfigurableBlockSideSettings.ACTIVE, "params": {}},
		"right": {"type": ConfigurableBlockSideSettings.ACTIVE, "params": {}},
		"top": {"type": ConfigurableBlockSideSettings.ACTIVE, "params": {}},
		"bottom": {"type": ConfigurableBlockSideSettings.ACTIVE, "params": {}},
		"bump": {"type": ConfigurableBlockSideSettings.ACTIVE, "params": {}},
		"stand": {"type": ConfigurableBlockSideSettings.ACTIVE, "params": {}},
		"any_side": {"type": ConfigurableBlockSideSettings.ACTIVE, "params": {}}
	},
	"custom_image": {
		"art_layers": []
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
	penciler.init(block_manager.block_layers, editor_events, null)
	
	var block
	#if BlockEditor.current_block:
		#block = BlockEditor.current_block
		#block_manager.decode_block(BlockEditor.current_block, true)
	#else:
		#var saved_block = FileManager.load_from_file()
		#if saved_block:
			#block = saved_block
			#block_manager.decode_block(saved_block, true)
		#else:
			#block = default_block
			#block_manager.decode_block(default_block, true)
	block = default_block
	block_manager.decode_block(default_block, true)
	
	#var block_settings: Dictionary = {}
	
	#block_manager.set_settings(block_settings)
	
	cursor.init(editor_menu, block_manager.block_layers)
	editor_menu.init(block_manager.block_layers, editor_events)
	editor_menu.cursor_is_enabled.connect(_on_cursor_is_enabled.bind())
	
	# layer_panel_node.init(level_manager.level_layers)
	
	camera_controls.init(editor_camera)
	
	editor_menu.control_event.connect(_on_control_event)
	# now_editing_panel.init($UI/EditorMenu, self)


func _on_back_pressed():
	#BlockEditor.current_block = block_manager.encode_block()
	#FileManager.save_to_file(BlockEditor.current_block, current_block_name)
	await Main.set_scene(Main.TITLE)


func _on_level_editor_pressed():
	#BlockEditor.current_block = block_manager.encode_block()
	#FileManager.save_to_file(BlockEditor.current_block, current_block_name)
	await Main.set_scene(Main.LEVEL_EDITOR)


func _on_save_pressed():
	BlockEditor.current_block = block_manager.encode_block()
	PopupManager.add_custom_popup(save_popup, {"mode": "block", "current_data": BlockEditor.current_block})


func _on_block_load(block_name = "", block_description = ""):
	#FileManager.set_current_block_name(block_name)
	#FileManager.set_current_block_description(block_description)
	
	#var selected_block = default_block
	#if (block_name != ""):
		#selected_block = FileManager.load_from_file(block_name)
		
	#block_manager.clear()
	#BlockEditor.current_block = selected_block
	#await get_tree().create_timer(0.1).timeout
	#block_manager.decode_level(selected_block, true)
	pass


func _on_control_event(event: Dictionary) -> void:
	pass
	


func _on_cursor_is_enabled(new_bool: bool) -> void:
	if new_bool:
		cursor.activate()
	else:
		cursor.deactivate()
	pass
