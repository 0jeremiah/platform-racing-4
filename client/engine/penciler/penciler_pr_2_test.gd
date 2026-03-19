extends Node2D

var pr2_level_id = "6518241"
var tiles: Tiles = Tiles.new()
@onready var http_request: HTTPRequest = $HTTPRequest
@onready var level_decoder: Node2D = $LevelDecoder
@onready var level_layers: LevelLayers = $Layers
@onready var penciler: Node2D = $Penciler
@onready var camera_2d: Camera2D = $Camera2D


func _ready() -> void:
	http_request.request_completed.connect(self._http_request_completed)
	http_request.request(ApiManager.get_base_url() + "/pr2/level/" + pr2_level_id)
	penciler.init(level_layers, level_decoder)
	tiles.init_defaults()
	level_layers.init(tiles)

 
func _http_request_completed(_result, _response_code, _headers, body):
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var level_data = json.get_data()
	level_decoder.decode(level_data, level_layers)
	
	tiles.activate_node(level_layers)
	var start_option = Start.get_next_start_option(level_layers)
	camera_2d.position = start_option.coords * Settings.tile_size
	camera_2d.position += Vector2(-350, 300)
