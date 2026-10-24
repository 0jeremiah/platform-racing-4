class_name BlockList

var block_array = []
var initialized: bool = false
var block_id: String = ""


func _init(tile_map_layer: ConfigurableTileMapLayer, coords: Vector2i) -> void:
	var block_info = tile_map_layer.get_block(coords)
	block_id = block_info.id
	if block_info.settings.temporary:
		pass # some function to connect to when the block is initalized goes here
	else:
		init_list(tile_map_layer, coords)


func get_block_info(tile_map_layer: ConfigurableTileMapLayer, coords: Vector2i) -> Dictionary:
	return {"tile_map_layer": tile_map_layer, "coords": coords, "map_layer": tile_map_layer.map_layer}


func remove_block(tile_map_layer: ConfigurableTileMapLayer, coords: Vector2i) -> void:
	var loc_2: int = block_array.find(get_block_info(tile_map_layer, coords))
	if loc_2 > -1:
		block_array.remove_at(loc_2)


func add_block(tile_map_layer: ConfigurableTileMapLayer, coords: Vector2i) -> void:
	block_array.push_back(get_block_info(tile_map_layer, coords))


func init_list(tile_map_layer: ConfigurableTileMapLayer, coords: Vector2i) -> void:
	initialized = true
