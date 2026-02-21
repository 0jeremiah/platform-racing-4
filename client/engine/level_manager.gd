extends Node
class_name LevelManager

@onready var layers: Layers = $Layers
@onready var level_decoder: LevelDecoder = $LevelDecoder
@onready var level_encoder: LevelEncoder = $LevelEncoder

var tiles: Tiles = Tiles.new()
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
	tiles.init_defaults()
	layers.init(tiles)


func encode_level() -> Dictionary:
	var bg = get_parent().get_node("BG")
	return level_encoder.encode(layers, bg, self)


func decode_level(level_data: Dictionary, is_editor: bool) -> void:
	level_decoder.decode(level_data, is_editor, layers)


func clear() -> void:
	layers.clear()
	tiles.clear()


func activate_node() -> void:
	tiles.activate_node(layers)


func calc_used_rect() -> void:
	layers.calc_used_rect()


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
