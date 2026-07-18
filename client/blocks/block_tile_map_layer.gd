extends TileMapLayer
class_name ConfigurableTileMapLayer
## TileMapLayer extension that works with ConfigurableBlock system
##
## Provides convenience methods to place tiles by block ID instead of requiring
## knowledge of source IDs and atlas coordinates.


#var _block_lookup: Dictionary = {}  # block_id → {source_id: int, atlas_coords: Vector2i}
#var _blocks: Dictionary = {}  # block_id → ConfigurableBlock instance
const EGG_ENEMY = preload("res://tiles/egg/egg_enemy.tscn")
var map_layer: MapLayer = null


## Set a cell by block ID instead of atlas coordinates
func set_cell_by_id(coords: Vector2i, block_id: String, alt_id: int = ConfigurableBlock.VISIBLE_ALT_ID) -> void:
	var tile_info: Dictionary = BlockManager._block_lookup.get(block_id, {})
	if tile_info.is_empty():
		push_warning("Block ID not found: " + block_id)
		return

	set_cell(coords, tile_info.source_id, tile_info.atlas_coords, alt_id)


## Get cell block ID from coordinates (reverse lookup)
func get_cell_block_id(coords: Vector2i) -> String:
	var source_id := get_cell_source_id(coords)
	var atlas_coords := get_cell_atlas_coords(coords)

	for block_id in BlockManager._block_lookup:
		var info: Dictionary = BlockManager._block_lookup[block_id]
		if info.source_id == source_id and info.atlas_coords == atlas_coords:
			return block_id

	return ""


func is_solid(coords: Vector2i) -> bool:
	var block_id = get_cell_block_id(coords)
	if block_id:
		return BlockManager._blocks[block_id].settings.matter_type == ConfigurableBlockSettings.SOLID
	return false


func is_liquid(coords: Vector2i) -> bool:
	var block_id = get_cell_block_id(coords)
	if block_id:
		return BlockManager._blocks[block_id].settings.matter_type == ConfigurableBlockSettings.LIQUID
	return false


func is_safe(coords: Vector2i) -> bool:
	var unsafe_matter_types = [ConfigurableBlockSettings.GAS]
	var unsafe_block_types = [ConfigurableBlockSettings.MOVE]
	var unsafe_block_sides = [ConfigurableBlockSideSettings.MINE, ConfigurableBlockSideSettings.VANISH,
	ConfigurableBlockSideSettings.PUSH, ConfigurableBlockSideSettings.CRUMBLE,
	ConfigurableBlockSideSettings.SAFETY, ConfigurableBlockSideSettings.SHATTER]
	var block_id = get_cell_block_id(coords)
	if block_id:
		var matter_type_is_safe: bool = BlockManager._blocks[block_id].settings.matter_type not in unsafe_matter_types
		var block_type_is_safe: bool = BlockManager._blocks[block_id].settings.matter_type not in unsafe_block_types
		var block_side_types = BlockManager._blocks[block_id].settings.get_side_types()
		for block_side_type in block_side_types:
			if block_side_type in unsafe_block_sides:
				return false
		return matter_type_is_safe and block_type_is_safe
	return false


func get_start_positions() -> Array:
	var start_blocks = []
	for block in BlockManager._blocks:
		var block_instance = BlockManager._blocks[block]
		if block_instance.settings.block_type == ConfigurableBlockSettings.START_POSITION:
			start_blocks.append(block)
	var start_options = []
	for start_block in start_blocks:
		var coord_list = get_used_cells_by_id(BlockManager._block_lookup[start_block].source_id, BlockManager._block_lookup[start_block].atlas_coords)
		for coords in coord_list:
			var start_option = {
				"tile_map_layer": self,
				"coords": coords,
				"map_layer_name": str(map_layer.name)
			}
			start_options.push_back(start_option)
	return start_options


func get_finish_blocks() -> Array:
	var finish_blocks = []
	for block in BlockManager._blocks:
		var block_instance = BlockManager._blocks[block]
		if block_instance.settings.has_side_type(ConfigurableBlockSideSettings.FINISH):
			finish_blocks.append(block)
	var finish_options = []
	for finish_block in finish_blocks:
		var coord_list = get_used_cells_by_id(BlockManager._block_lookup[finish_block].source_id, BlockManager._block_lookup[finish_block].atlas_coords)
		for coords in coord_list:
			var start_option = {
				"tile_map_layer": self,
				"coords": coords,
				"map_layer_name": str(map_layer.name)
			}
			finish_options.push_back(start_option)
	return finish_options


func spawn_eggs():
	var egg_blocks = []
	for block in BlockManager._blocks:
		var block_instance = BlockManager._blocks[block]
		if block_instance.settings.block_type == ConfigurableBlockSettings.EGG:
			egg_blocks.append(block)
	for egg in egg_blocks:
		var egg_counter = 0
		var coord_list = get_used_cells_by_id(BlockManager._block_lookup[egg].source_id, BlockManager._block_lookup[egg].atlas_coords)
		for coords in coord_list:
			egg_counter += 1
			var egg_enemy = EGG_ENEMY.instantiate()
			var depth = Helpers.get_depth(map_layer)
			egg_enemy.position = BlockManager._blocks[egg].get_center_position(self, coords)
			egg_enemy.name = "EggEnemy" + str(egg_counter)
			map_layer.enemies.add_child(egg_enemy)
			egg_enemy.set_depth(depth)
			BlockManager._blocks[egg].deactivate(self, coords)
			BlockManager._blocks[egg].set_visible(self, coords, false)
			erase_cell(coords)


func get_teleport_positions_at_block_id(block_id: String) -> Array:
	if !block_id in BlockManager._blocks and block_id in BlockManager._block_lookup:
		return []
	var teleport_block = BlockManager._blocks[block_id]
	if !teleport_block.settings.has_side_type(ConfigurableBlockSideSettings.TELEPORT):
		return []
	var teleport_positions = []
	var coord_list = get_used_cells_by_id(BlockManager._block_lookup[block_id].source_id, BlockManager._block_lookup[block_id].atlas_coords)
	for coords in coord_list:
		var teleport_position = {
			"color": BlockManager._blocks[block_id].settings.teleport_color,
			"tile_map_layer": self,
			"coords": coords,
			"map_layer_name": str(map_layer.name),
		}
		teleport_positions.push_back(teleport_position)
	return teleport_positions

## Create ConfigurableBlock instances from configs
func _create_blocks(configs: Array) -> void:
	BlockManager._blocks.clear()

	for config in configs:
		if not config.has("id"):
			continue

		var block_id: String = config.id
		var block := ConfigurableBlock.new()
		block.init(config)
		BlockManager._blocks[block_id] = block


## Trigger block behaviors for a tile collision
func trigger_tile_behaviors(body: PhysicsBody2D, coords: Vector2i, events: Array[String], normal: Vector2 = Vector2.ZERO) -> void:
	var block_id := get_cell_block_id(coords)
	if block_id == "":
		return

	var block: ConfigurableBlock = BlockManager._blocks.get(block_id)
	if not block:
		return

	for event in events:
		block.on(event, body, self, coords, normal)
