extends BlockList
class_name ChangeBlockList

var pattern: Array = ConfigurableBlockSettings.default_block_properties.change_pattern
var index: int = 0
var max_index: int = pattern.size() - 1


func _init(tile_map_layer: ConfigurableTileMapLayer, coords: Vector2i) -> void:
	super(tile_map_layer, coords)


func get_needed_blocks() -> Array:
	var loc_1: Array = []
	var loc_2: Array = []
	for pattern_id in pattern:
		if loc_1.find(pattern_id) == -1:
			loc_1.append(pattern_id)
			loc_2.append(pattern_id)
	return loc_2


func execute_change() -> void:
	var loc_1: String = ""
	if initialized:
		loc_1 = pattern[index]
		# if pr3's BlockManager.requestBlock is needed we will add it
		# but for now we use our BlockManagers' _block_lookup
		var block_settings = ConfigurableBlockSettings.new()
		block_settings.import_settings(BlockManager._block_lookup[loc_1].settings)
		for block_info in block_array:
			var block_node = block_info.tile_map_layer.get_block(block_info.coords).node
			if block_node:
				block_node.morph_block_type(loc_1, block_settings)
		index += 1
		if index > max_index:
			index = 0


func init_list(tile_map_layer: ConfigurableTileMapLayer, coords: Vector2i) -> void:
	super(tile_map_layer, coords)
	var block_info = tile_map_layer.get_block(coords)
	if block_info.settings.change_pattern.size() > 0:
		pattern = block_info.settings.change_pattern
	max_index = block_info.settings.change_pattern.size() - 1
