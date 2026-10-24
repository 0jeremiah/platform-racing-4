class_name BlockFreqGroup

var elasped_time: float = 0.0
var block_lists: Dictionary = {}
var freq: float = 0.0


func _init(new_freq: float) -> void:
	freq = new_freq


func remove_block(tile_map_layer: ConfigurableTileMapLayer, coords: Vector2i) -> void:
	var loc_2: BlockList = get_block_list(tile_map_layer, coords)
	loc_2.remove_block(tile_map_layer, coords)


func step(param_1: float) -> void:
	elasped_time += param_1
	if elasped_time >= freq:
		elasped_time -= freq
		trigger_interval()


func create_block_list(tile_map_layer: ConfigurableTileMapLayer, coords: Vector2i) -> BlockList:
	var new_block_list = BlockList.new(tile_map_layer, coords)
	return new_block_list


func get_block_list(tile_map_layer: ConfigurableTileMapLayer, coords: Vector2i) -> BlockList:
	var block_info = tile_map_layer.get_block(coords)
	var loc_2: String = block_info.id
	var loc_3: BlockList = block_lists.get(loc_2)
	if loc_3 == null:
		loc_3 = create_block_list(tile_map_layer, coords)
		block_lists[loc_2] = loc_3
	return loc_3


func add_block(tile_map_layer: ConfigurableTileMapLayer, coords: Vector2i) -> void:
	var settings = tile_map_layer.get_block(coords).settings
	if settings != null and settings.temporary:
		pass
	var loc_2: BlockList = get_block_list(tile_map_layer, coords)
	loc_2.add_block(tile_map_layer, coords)


func trigger_interval() -> void:
	pass
