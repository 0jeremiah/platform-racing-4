extends Node2D
class_name RandomBlockItem

@onready var timer = $Timer
@onready var tile_atlas = $TileAtlas
var character: Character
var tile_id: String = "1"
var using: bool = false
var remove: bool = false


func _ready():
	timer.connect("timeout", _on_timeout)
	_set_random_tile_id()


func _on_timeout():
	_set_random_tile_id()


func _set_random_tile_id() -> void:
	tile_id = str(randi_range(1, 39))


func activate_item():
	using = true
	var layer = Game.get_target_map_layer_node()
	var tile_map_layer: ConfigurableTileMapLayer = layer.tile_map_layer
	var global_position = to_global(Vector2(0, 0))
	var tile_map_layer_position = tile_map_layer.to_local(global_position)
	var coords: Vector2i = Vector2i(tile_map_layer_position.round()) / Settings.tile_size
	#var atlas_coords: Vector2i = CoordinateUtils.to_atlas_coords(tile_id)
	#tile_map_layer.set_cell(coords, 0, atlas_coords)
	remove = true


func still_have_item():
	if !remove:
		return true
	else:
		return false
