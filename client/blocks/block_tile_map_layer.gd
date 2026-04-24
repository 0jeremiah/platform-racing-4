extends TileMapLayer
class_name ConfigurableTileMapLayer
## TileMapLayer extension that works with ConfigurableBlock system
##
## Provides convenience methods to place tiles by block ID instead of requiring
## knowledge of source IDs and atlas coordinates.


var _block_lookup: Dictionary = {}  # block_id → {source_id: int, atlas_coords: Vector2i}
var _blocks: Dictionary = {}  # block_id → ConfigurableBlock instance


## Initialize the layer with a ConfigurableTileSet
func setup_from_configs(configs: Array) -> void:
	# Create and assign tileset
	var tileset := ConfigurableTileSet.create_from_configs(configs)
	tile_set = tileset

	# Build lookup table: block_id → tile info
	_build_block_lookup(configs, tileset)

	# Create block instances
	_create_blocks(configs)


## Build the block_id → tile location mapping
func _build_block_lookup(configs: Array, tileset: ConfigurableTileSet) -> void:
	_block_lookup.clear()

	# Group configs by texture to match ConfigurableTileSet's source creation logic
	var source_id := 0
	var textures_seen: Array[String] = []

	for config in configs:
		if not config.has("id") or not config.has("image"):
			continue

		var block_id: String = config.id
		var texture_path: String = config.image.get("src", "")

		# Track which source_id this texture gets
		var texture_source_id := source_id
		if texture_path not in textures_seen:
			textures_seen.append(texture_path)
			source_id += 1
		else:
			texture_source_id = textures_seen.find(texture_path)

		# Store the mapping
		_block_lookup[block_id] = {
			"source_id": texture_source_id,
			"atlas_coords": Vector2i(
				config.image.atlas_coords.get("x", 0),
				config.image.atlas_coords.get("y", 0)
			)
		}


## Set a cell by block ID instead of atlas coordinates
func set_cell_by_id(coords: Vector2i, block_id: String, alt_id: int = ConfigurableBlock.VISIBLE_ALT_ID) -> void:
	var tile_info: Dictionary = _block_lookup.get(block_id, {})
	if tile_info.is_empty():
		push_warning("Block ID not found: " + block_id)
		return

	set_cell(coords, tile_info.source_id, tile_info.atlas_coords, alt_id)


## Get cell block ID from coordinates (reverse lookup)
func get_cell_block_id(coords: Vector2i) -> String:
	var source_id := get_cell_source_id(coords)
	var atlas_coords := get_cell_atlas_coords(coords)

	for block_id in _block_lookup:
		var info: Dictionary = _block_lookup[block_id]
		if info.source_id == source_id and info.atlas_coords == atlas_coords:
			return block_id

	return ""


## Create ConfigurableBlock instances from configs
func _create_blocks(configs: Array) -> void:
	_blocks.clear()

	for config in configs:
		if not config.has("id"):
			continue

		var block_id: String = config.id
		var block := ConfigurableBlock.new()
		block.init(config)
		_blocks[block_id] = block


## Trigger block behaviors for a tile collision
func trigger_tile_behaviors(body: PhysicsBody2D, coords: Vector2i, events: Array[String]) -> void:
	var block_id := get_cell_block_id(coords)
	if block_id == "":
		return

	var block: ConfigurableBlock = _blocks.get(block_id)
	if not block:
		return

	for event in events:
		block.on(event, body, self, coords)
