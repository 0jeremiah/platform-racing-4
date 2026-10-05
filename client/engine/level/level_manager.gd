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

var level_type: String = "race"
var time: int = 120
var gravity: float = 1.0
var items: Array = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]
var start_position_blocks = []
var finish_blocks = []
var reached_finish_blocks = []
var teleport_blocks = {}
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


func register_start_block(block: BlockScene):
	start_position_blocks.append({"tile_map_layer": block.tile_map_layer, "coords": block.get_coords(), "map_layer_name": str(block.tile_map_layer.map_layer.name)})


func remove_start_block(block: BlockScene):
	var block_to_remove = {"tile_map_layer": block.tile_map_layer, "coords": block.get_coords(), "map_layer_name": str(block.tile_map_layer.map_layer.name)}
	start_position_blocks.filter(func(start_position): return start_position != block_to_remove)


func register_move_block(block: BlockScene):
	block_interval_manager.add_block(block, BlockIntervalManager.TYPE_MOVE)


func remove_move_block(block: BlockScene):
	block_interval_manager.remove_block(block, BlockIntervalManager.TYPE_MOVE)


func register_change_block(block: BlockScene):
	block_interval_manager.add_block(block, BlockIntervalManager.TYPE_CHANGE)


func remove_change_block(block: BlockScene):
	block_interval_manager.remove_block(block, BlockIntervalManager.TYPE_CHANGE)


func register_finish_block(block: BlockScene):
	finish_blocks.append({"tile_map_layer": block.tile_map_layer, "coords": block.get_coords(), "map_layer_name": str(block.tile_map_layer.map_layer.name)})


func remove_finish_block(block: BlockScene):
	var block_to_remove = {"tile_map_layer": block.tile_map_layer, "coords": block.get_coords(), "map_layer_name": str(block.tile_map_layer.map_layer.name)}
	finish_blocks.filter(func(finish_position): return finish_position != block_to_remove)
	reached_finish_blocks.filter(func(finish_position): return finish_position != block_to_remove)


func register_teleport_block(block: BlockScene):
	if !teleport_blocks.has(block.id):
		teleport_blocks[block.id] = []
	teleport_blocks[block.id].append({"tile_map_layer": block.tile_map_layer, "coords": block.get_coords(), "map_layer_name": str(block.tile_map_layer.map_layer.name), "color": block.settings.teleport_color})


func remove_teleport_block(block: BlockScene):
	if teleport_blocks.has(block.id):
		var block_index = teleport_blocks[block.id].find({"tile_map_layer": block.tile_map_layer, "coords": block.get_coords(), "map_layer_name": str(block.tile_map_layer.map_layer.name), "color": block.settings.teleport_color})
		if block_index > -1:
			teleport_blocks[block.id].remove_at(block_index)
		if teleport_blocks[block.id].size() == 0:
			teleport_blocks.erase(block.id)


func update_finish_blocks(block: BlockScene):
	var block_to_add = {"tile_map_layer": block.tile_map_layer, "coords": block.get_coords(), "map_layer_name": str(block.tile_map_layer.map_layer.name)}
	#var level_manager = Game.game.level_manager
	if block_to_add in finish_blocks and block_to_add not in reached_finish_blocks:
		reached_finish_blocks.append(block_to_add)
	#level_manager.level_layers.get_all_finish_blocks()
	#finish_blocks = level_manager.level_layers.all_finish_blocks
	#for finish_block in finish_blocks:
		#if finish_block.tile_map_layer == tile_map_layer and finish_block.coords == coords and !finish_block.reached:
			#reached_finish_blocks += 1
			#finish_block.reached = true
			#var settings = tile_map_layer.get_block(coords).settings
			#settings.can_finish = false
			#break


func init_level():
	calc_used_rect()
	level_layers.spawn_gears()
	level_layers.get_all_start_options()
	reached_finish_blocks = 0
	level_layers.get_all_finish_blocks()
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
