extends Node2D
class_name EditorEvents

signal editor_event
signal send_editor_event

# control events, switching tools, swtiching selected block, etc
const SELECT_TOOL = 'select_tool'
const SELECT_LAYER = 'select_layer'
const SELECT_MAP_LAYER = 'select_map_layer'
const SELECT_ART_LAYER = 'select_art_layer'
const ENABLE_COLLAB = 'enable_collab'
const DISABLE_COLLAB = 'disable_collab'
const SELECT_BLOCK = 'select_block'
const SELECT_BLOCK_MODE = 'select_block_mode'
const SELECT_BRUSH_MODE = 'select_brush_mode'
const SELECT_DRAW_COLOR = 'select_draw_color'
const SELECT_DRAW_SIZE = 'select_draw_size'
const SELECT_DRAW_ALPHA = 'select_draw_alpha'
const SELECT_ERASE_SIZE = 'select_erase_size'
const SELECT_ERASE_ALPHA = 'select_erase_alpha'
const SELECT_STAMP = 'select_stamp'
const SELECT_STAMP_MODE = 'select_stamp_mode'
const SELECT_STAMP_SIZE = 'select_stamp_size'
const SELECT_STAMP_ROTATION = 'select_stamp_rotation'
const SELECT_TEXT_COLOR = 'select_text_color'
const SELECT_TEXT_SIZE = 'select_text_size'
const SELECT_TEXT_ROTATION = 'select_text_rotation'
const SET_BACKGROUND = 'set_background'
const SET_MUSIC = 'set_music'
const SET_LEVEL_TYPE = 'set_level_type'
const SET_TIME = 'set_time'
const SET_GRAVITY = 'set_gravity'
const SET_PASSWORD = 'set_password'
const SET_SFCHM_CHANCE = 'set_sfchm_chance'
const SET_WIND_CHANCE = 'set_wind_chance'
const SET_SNOW_CHANCE = 'set_snow_chance'
const SET_ALIEN_CHANCE = 'set_alien_chance'
const SET_ITEMS = 'set_items'

# editor events, adding blocks, drawing, changeing a setting, etc
const ADD_MAP_LAYER = 'add_map_layer'
const ADD_ART_LAYER = 'add_art_layer'
const SET_MAP_LAYER_ROTATION = 'set_map_layer_rotation'
const SET_ART_LAYER_ROTATION = 'set_art_layer_rotation'
const RENAME_MAP_LAYER = 'rename_map_layer'
const RENAME_ART_LAYER = 'rename_art_layer'
const SET_MAP_LAYER_Z_AXIS = 'set_map_layer_z_axis'
const SET_ART_LAYER_Z_AXIS = 'set_art_layer_z_axis'
const SET_ART_LAYER_ALPHA = 'set_art_layer_alpha'
const SET_ART_LAYER_DEPTH = 'set_art_layer_depth'
const SET_MAP_LAYER_ANCHOR = 'set_map_layer_anchor'
const SET_ART_LAYER_ANCHOR = 'set_art_layer_anchor'
const SET_ART_LAYER_BLOCK_EFFECTS = "set_art_layer_block_effects"
const SET_MAP_LAYER_Z_INDEX = 'set_map_layer_z_index'
const SET_ART_LAYER_Z_INDEX = 'set_art_layer_z_index'
const DELETE_MAP_LAYER = 'delete_map_layer'
const DELETE_ART_LAYER = 'delete_art_layer'
const SET_TILE = 'set_tile'
const MOVE_TILE = 'move_tile'
const ADD_LINE = 'add_line'
const ADD_STAMP = 'add_stamp'
const SET_STAMP_POSITION = 'set_stamp_position'
const SET_STAMP_SCALE = 'set_stamp_scale'
const SET_STAMP_ROTATION = 'set_stamp_rotation'
const DELETE_STAMP = 'delete_stamp'
const ADD_TEXT = 'add_text'
const SET_TEXT = 'set_text'
const SET_TEXT_COLOR = 'set_text_color'
const SET_TEXT_SIZE = 'set_text_size'
const ROTATE_TEXT = 'rotate_text'
const SET_TEXT_FONT = 'set_text_font'
const DELETE_TEXT = 'delete_text'
const SET_BLOCK_SETTINGS = "set_block_settings"
const UNDO = 'undo'

var events = []
var redo_events = []
var last_send_event: Dictionary = {}
var game_client: Node2D


func set_game_client(p_game_client) -> void:
	game_client = p_game_client
	game_client.connect("receive_editor_event", _on_receive_editor_event)


func connect_to(nodes: Array) -> void:
	for node in nodes:
		node.connect("editor_event", _on_editor_event)


func _on_editor_event(event: Dictionary) -> void:
	if event == last_send_event:
		return
		
	last_send_event = event
	if len(redo_events) > 0:
		redo_events = []
	events.push_back(event)
	
	if !game_client || !game_client.is_live_editing:
		# Single-player editor editor
		emit_signal("editor_event", event)
	else:
		# Muti-player editor editor
		emit_signal("send_editor_event", event)


func _on_receive_editor_event(event: Dictionary) -> void:
	print("EditorEvents::_on_receive_editor_event ", event)
	if len(redo_events) > 0:
		redo_events = []
	events.push_back(event)
	emit_signal("editor_event", event)


func undo() -> void:
	var event = events.pop_back()
	redo_events.push_back(event)
	var undo_event = {
		"type": UNDO,
		"event": event
	}
	emit_signal("editor_event", undo_event)


func redo() -> void:
	if len(redo_events) == 0:
		return
	var event = redo_events.pop_back()
	events.push_back(event)
	emit_signal("editor_event", event)
