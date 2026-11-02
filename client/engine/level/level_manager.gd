extends Node
class_name LevelManager

@onready var level_layers: LevelLayers = $LevelLayers
@onready var level_decoder: LevelDecoder = $LevelDecoder
@onready var level_encoder: LevelEncoder = $LevelEncoder
@onready var pr2_level_decoder: PR2LevelDecoder = $PR2LevelDecoder
@onready var block_interval_manager: BlockIntervalManager = $BlockIntervalManager

static var race = "race"
static var deathmatch = "deathmatch"
static var hat_attack = "hatAttack"
static var coin_fiend = "coinFiend"
static var objective = "objective"
static var alien_eggs = "alienEggs"
static var roguelike = "roguelike"

var level_type: String = race
var time: int = 120
var gravity: float = 1.0
var items: Array = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]
var block_list = {"block_type_list": {}, "side_setting_list": {}}
var start_position_index: int = 0
var reached_finish_blocks = []
var background_id = "pr2_field"
var fade_color = "FFFFFF"
var music: String = "random"
var password: String = ""
var sfchm_chance: int = 0
var wind_chance: int = 0
var snow_chance: int = 0
var alien_chance: int = 0
var error: bool = false


func _ready() -> void:
	level_decoder.control_event.connect(_on_control_event)


func encode_level() -> Dictionary:
	return level_encoder.encode(level_layers, self)


func new_encode_level() -> Dictionary:
	return level_encoder.new_encode(level_layers, self)


func decode_level(level_data: Dictionary) -> void:
	level_decoder.decode(level_data)


func new_decode_level(level_data: Dictionary) -> void:
	level_decoder.new_decode(level_data)


func decode_pr2_level(raw_pr2_level_data: String) -> void:
	var pr2_level = pr2_level_decoder.decode_pr2_level(raw_pr2_level_data)
	if pr2_level.is_empty():
		error = true
		return
	level_decoder.new_decode(pr2_level)


func clear() -> void:
	background_id = "pr2_field"
	fade_color = "FFFFFF"
	music = "random"
	password = ""
	sfchm_chance = 0
	wind_chance = 0
	snow_chance = 0
	alien_chance = 0
	level_layers.clear()


func calc_used_rect() -> void:
	level_layers.calc_used_rect()


func get_next_start_position():
	var start_position_blocks = block_list.block_type_list.get(ConfigurableBlockSettings.START_POSITION, [])
	if start_position_blocks.size() > 0:
		if start_position_index >= start_position_blocks.size():
			start_position_index = 0
		var start_position = start_position_blocks[start_position_index]
		if start_position_index + 1 >= start_position_blocks.size():
			start_position_index = 0
		else:
			start_position_index += 1
		return start_position
	else:
		var target_map_layer = level_layers.map_layers.get_node(level_layers.get_target_map_layer())
		return {
			"tile_map_layer": target_map_layer.tile_map_layer,
			"coords": Vector2i(0, 0),
			"map_layer_name": str(target_map_layer.name)
		}


func register_block(tile_map_layer: ConfigurableTileMapLayer, coords: Vector2i):
	#var do_not_include_settings = [ConfigurableBlockSettings.ACTIVE, ConfigurableBlockSettings.IMPERVIOUS, ConfigurableBlockSettings.INACTIVE]
	#var do_not_include_side_settings = [ConfigurableBlockSettings.ACTIVE, ConfigurableBlockSettings.INACTIVE]
	var block_info = tile_map_layer.get_block(coords)
	if block_info.settings != null:
		#if block_info.settings.block_type not in do_not_include_settings:
		if !block_list.block_type_list.has(block_info.settings.block_type):
			block_list.block_type_list[block_info.settings.block_type] = []
		var block_type = {"tile_map_layer": tile_map_layer, "coords": coords, "map_layer_name": str(tile_map_layer.map_layer.name)}
		if !block_list.block_type_list[block_info.settings.block_type].has(block_type):
			block_list.block_type_list[block_info.settings.block_type].append(block_type)
			if block_info.settings.block_type == ConfigurableBlockSettings.MOVE:
				block_interval_manager.add_block(tile_map_layer, coords, BlockIntervalManager.TYPE_MOVE)
			if block_info.settings.block_type == ConfigurableBlockSettings.CHANGE:
				block_interval_manager.add_block(tile_map_layer, coords, BlockIntervalManager.TYPE_CHANGE)
		var block_sides = block_info.settings.get_side_types()
		for block_side in block_sides:
			#if block_side not in do_not_include_side_settings:
			if !block_list.side_setting_list.has(block_side):
				block_list.side_setting_list[block_side] = []
			var block = {"tile_map_layer": tile_map_layer, "coords": coords, "map_layer_name": str(tile_map_layer.map_layer.name)}
			if block_side == ConfigurableBlockSideSettings.TELEPORT:
				block["teleport_color"] = block_info.settings.teleport_color
			if !block_list.side_setting_list[block_side].has(block):
				block_list.side_setting_list[block_side].append(block)


func unregister_block(tile_map_layer: ConfigurableTileMapLayer, coords: Vector2i, unregister_change: bool = true):
	#var do_not_include_settings = [ConfigurableBlockSettings.ACTIVE, ConfigurableBlockSettings.IMPERVIOUS, ConfigurableBlockSettings.INACTIVE]
	#var do_not_include_side_settings = [ConfigurableBlockSettings.ACTIVE, ConfigurableBlockSettings.INACTIVE]
	var block_info = tile_map_layer.get_block(coords)
	if block_info.settings != null:
		var block_type_to_remove = {"tile_map_layer": tile_map_layer, "coords": coords, "map_layer_name": str(tile_map_layer.map_layer.name)}
		if block_list.block_type_list.has(block_info.settings.block_type) and block_list.block_type_list[block_info.settings.block_type].has(block_type_to_remove):
			block_list.block_type_list[block_info.settings.block_type] = block_list.block_type_list[block_info.settings.block_type].filter(func(block_type): return block_type != block_type_to_remove)
			if block_list.block_type_list[block_info.settings.block_type].is_empty():
				block_list.block_type_list.erase(block_info.settings.block_type)
		if block_info.settings.block_type == ConfigurableBlockSettings.MOVE:
			block_interval_manager.remove_block(tile_map_layer, coords, BlockIntervalManager.TYPE_MOVE)
		if block_info.node != null:
			block_info.node.register_change_block = unregister_change
			if block_info.node.is_change_block and unregister_change:
				block_interval_manager.remove_block(tile_map_layer, coords, BlockIntervalManager.TYPE_CHANGE)
		var block_sides = block_info.settings.get_side_types()
		for block_side in block_sides:
			var block = {"tile_map_layer": tile_map_layer, "coords": coords, "map_layer_name": str(tile_map_layer.map_layer.name)}
			if block_side == ConfigurableBlockSideSettings.TELEPORT:
				block["teleport_color"] = block_info.settings.teleport_color
			if block_list.side_setting_list.has(block_side) and block_list.side_setting_list[block_side].has(block_type_to_remove):
				block_list.side_setting_list[block_side] = block_list.side_setting_list[block_side].filter(func(block_type): return block_type != block_type_to_remove)
				if block_list.side_setting_list[block_side].is_empty():
					block_list.side_setting_list.erase(block_side)
				if block_list.side_setting_list.has(ConfigurableBlockSideSettings.FINISH) and block_list.side_setting_list[ConfigurableBlockSideSettings.FINISH].has(block_type_to_remove):
					reached_finish_blocks = reached_finish_blocks.filter(func(block_type): return block_type != block_type_to_remove)


func register_move_block(tile_map_layer: ConfigurableTileMapLayer, coords: Vector2i):
	block_interval_manager.add_block(tile_map_layer, coords, BlockIntervalManager.TYPE_MOVE)


func remove_move_block(tile_map_layer: ConfigurableTileMapLayer, coords: Vector2i):
	block_interval_manager.remove_block(tile_map_layer, coords, BlockIntervalManager.TYPE_MOVE)


func register_change_block(tile_map_layer: ConfigurableTileMapLayer, coords: Vector2i):
	block_interval_manager.add_block(tile_map_layer, coords, BlockIntervalManager.TYPE_CHANGE)


func remove_change_block(tile_map_layer: ConfigurableTileMapLayer, coords: Vector2i):
	block_interval_manager.remove_block(tile_map_layer, coords, BlockIntervalManager.TYPE_CHANGE)


#func register_finish_block(tile_map_layer: ConfigurableTileMapLayer, coords: Vector2i):
	#finish_blocks.append({"tile_map_layer": tile_map_layer, "coords": coords, "map_layer_name": str(tile_map_layer.map_layer.name)})


#func remove_finish_block(tile_map_layer: ConfigurableTileMapLayer, coords: Vector2i):
	#var block_to_remove = {"tile_map_layer": tile_map_layer, "coords": coords, "map_layer_name": str(tile_map_layer.map_layer.name)}
	#finish_blocks.filter(func(block): return block != block_to_remove)
	#reached_finish_blocks.filter(func(block): return block != block_to_remove)


func add_to_reached_finish_blocks(tile_map_layer: ConfigurableTileMapLayer, coords: Vector2i):
	var block_to_add = {"tile_map_layer": tile_map_layer, "coords": coords, "map_layer_name": str(tile_map_layer.map_layer.name)}
	if block_list.side_setting_list.has(ConfigurableBlockSideSettings.FINISH) and block_list.side_setting_list[ConfigurableBlockSideSettings.FINISH].has(block_to_add) and block_to_add not in reached_finish_blocks:
		reached_finish_blocks.append(block_to_add)


func init_level():
	calc_used_rect()
	level_layers.spawn_gears()
	reached_finish_blocks = []
	level_layers.spawn_eggs()


func _on_control_event(event: Dictionary):
	set_settings(event)


func set_settings(new_settings: Dictionary):
	if new_settings.has("bg"):
		background_id = new_settings.bg
	if new_settings.has("fade_color"):
		fade_color = new_settings.fade_color
	if new_settings.has("music"):
		music = new_settings.music
	if new_settings.has("level_type"):
		level_type = new_settings.level_type
	if new_settings.has("music"):
		music = new_settings.music
	if new_settings.has("level_type"):
		level_type = new_settings.level_type
	if new_settings.has("time"):
		time = new_settings.time
	if new_settings.has("gravity"):
		gravity = new_settings.gravity
	if new_settings.has("password"):
		password = new_settings.password
	if new_settings.has("sfchm_chance"):
		sfchm_chance = new_settings.sfchm_chance
	if new_settings.has("wind_chance"):
		wind_chance = new_settings.wind_chance
	if new_settings.has("snow_chance"):
		snow_chance = new_settings.snow_chance
	if new_settings.has("alien_chance"):
		alien_chance = new_settings.alien_chance
	if new_settings.has("items"):
		items = new_settings.items
