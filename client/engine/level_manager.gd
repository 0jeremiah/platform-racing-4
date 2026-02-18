extends Node
class_name LevelManager

@onready var layers: Layers = $Layers
@onready var level_decoder: LevelDecoder = $LevelDecoder
@onready var level_encoder: LevelEncoder = $LevelEncoder

var tiles: Tiles = Tiles.new()
var music: String = "random"
var items: Array = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]
var time: int = 120


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
