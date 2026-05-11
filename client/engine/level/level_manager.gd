extends Node
class_name LevelManager

@onready var level_layers: LevelLayers = $LevelLayers
@onready var level_decoder: LevelDecoder = $LevelDecoder
@onready var level_encoder: LevelEncoder = $LevelEncoder

var default_blocks_config: Array = []
var music: String = "random"
var level_type: String = "race"
var time: int = 120
var gravity: float = 1.0
var password: String = ""
var sfchm_chance: int = 0
var wind_chance: int = 0
var snow_chance: int = 0
var alien_chance: int = 0
var items: Array = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]


func _ready() -> void:
	default_blocks_config = BlockManager._load_default_block_configs()
	level_layers.init(default_blocks_config)


func encode_level() -> Dictionary:
	var bg = get_parent().get_node("BG")
	return level_encoder.encode(level_layers, bg, self)


func decode_level(level_data: Dictionary) -> void:
	level_decoder.decode(level_data, level_layers)
	level_layers.get_all_start_options()


func clear() -> void:
	level_layers.clear()
	#tiles.clear()


#func activate_node() -> void:
	#tiles.activate_node(level_layers)


func calc_used_rect() -> void:
	level_layers.calc_used_rect()


func set_settings(new_settings: Dictionary):
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
