class_name ConfigurableTileSet
extends TileSet
## TileSet that is dynamically generated from an array of block configuration dictionaries
##
## Takes block configs (from JSON or runtime) and creates a complete TileSet with:
## - Multiple atlas sources (deduplicated by texture)
## - Physics layers for different matter types
## - Alternative tiles for visible/invisible/active/deactivated states


## Initialize the tileset from an array of block configuration dictionaries
func init(configs: Array) -> void:
	# Set tile size from settings
	tile_size = Settings.tile_size

	# Setup physics layers
	_setup_physics_layers()

	# Group configs by texture source to deduplicate atlases
	var sources_map: Dictionary = _group_by_texture(configs)

	# Create atlas sources and tiles
	_create_atlas_sources(sources_map)


## Setup physics layers: layer 0 for solid, layer 1 for non-solid (liquid/gas)
func _setup_physics_layers() -> void:
	add_physics_layer()  # Layer 0: solid blocks
	add_physics_layer()  # Layer 1: non-solid blocks (liquid, gas)


## Group configs by their texture source path to deduplicate atlases
func _group_by_texture(configs: Array) -> Dictionary:
	var sources_map: Dictionary = {}

	for config in configs:
		if not config.has("image"):
			push_warning("Config missing 'image' field: " + str(config.get("id", "unknown")))
			continue

		var image_data: Dictionary = config.image
		var texture_path: String = image_data.get("src", "")

		if texture_path.is_empty():
			push_warning("Config missing 'image.src': " + str(config.get("id", "unknown")))
			continue

		# Group configs by texture path
		if not sources_map.has(texture_path):
			sources_map[texture_path] = []
		sources_map[texture_path].append(config)

	return sources_map


## Create TileSetAtlasSource for each unique texture and populate with tiles
func _create_atlas_sources(sources_map: Dictionary) -> void:
	var source_id: int = 0

	for texture_path in sources_map:
		var configs: Array = sources_map[texture_path]

		# Load the texture
		var texture: Texture2D = load(texture_path)
		if not texture:
			push_error("Failed to load texture: " + texture_path)
			continue

		# Create atlas source
		var atlas_source: TileSetAtlasSource = TileSetAtlasSource.new()
		atlas_source.texture = texture
		atlas_source.texture_region_size = Settings.tile_size

		# Add source to tileset
		add_source(atlas_source, source_id)

		# Create tiles for all configs using this texture
		for config in configs:
			_create_tile_from_config(atlas_source, config)

		source_id += 1


## Create a tile and its alternatives from a config dictionary
func _create_tile_from_config(atlas_source: TileSetAtlasSource, config: Dictionary) -> void:
	var image_data: Dictionary = config.image
	var atlas_coords := Vector2i(
		image_data.atlas_coords.get("x", 0),
		image_data.atlas_coords.get("y", 0)
	)

	# Create the base tile
	atlas_source.create_tile(atlas_coords)

	# Create alternative tiles
	atlas_source.create_alternative_tile(atlas_coords, ConfigurableBlock.INVISIBLE_ALT_ID)
	atlas_source.create_alternative_tile(atlas_coords, ConfigurableBlock.DEACTIVATED_ALT_ID)
	atlas_source.create_alternative_tile(atlas_coords, ConfigurableBlock.INVISIBLE_DEACTIVATED_ALT_ID)

	# Get matter type from config
	var matter_type: String = config.settings.get("matter_type", ConfigurableBlockSettings.SOLID)

	# Setup collision and appearance for all alternative tiles
	_setup_tile_alternatives(atlas_source, atlas_coords, matter_type)


## Setup collision polygons and modulation for all tile alternatives
func _setup_tile_alternatives(atlas_source: TileSetAtlasSource, atlas_coords: Vector2i, matter_type: String) -> void:
	# Create collision polygon (full square)
	var polygon := PackedVector2Array([
		Vector2(-Settings.tile_size_half.x, -Settings.tile_size_half.y),
		Vector2(Settings.tile_size_half.x, -Settings.tile_size_half.y),
		Vector2(Settings.tile_size_half.x, Settings.tile_size_half.y),
		Vector2(-Settings.tile_size_half.x, Settings.tile_size_half.y)
	])

	# Physics layer: 0 for solid, 1 for non-solid
	var physics_layer: int = 0 if matter_type == ConfigurableBlockSettings.SOLID else 1

	# Setup all alternative tiles
	var alt_ids := [
		ConfigurableBlock.VISIBLE_ALT_ID,
		ConfigurableBlock.INVISIBLE_ALT_ID,
		ConfigurableBlock.DEACTIVATED_ALT_ID,
		ConfigurableBlock.INVISIBLE_DEACTIVATED_ALT_ID
	]

	for alt_id in alt_ids:
		var tile_data: TileData = atlas_source.get_tile_data(atlas_coords, alt_id)

		# Add collision polygon
		tile_data.add_collision_polygon(physics_layer)
		tile_data.set_collision_polygon_points(physics_layer, 0, polygon)

		# Apply modulation based on state
		if alt_id == ConfigurableBlock.DEACTIVATED_ALT_ID:
			tile_data.modulate = Color(0.5, 0.5, 0.5, 1.0)  # Grayed out
		elif alt_id == ConfigurableBlock.INVISIBLE_ALT_ID:
			tile_data.modulate = Color(1.0, 1.0, 1.0, 0.0)  # Transparent
		elif alt_id == ConfigurableBlock.INVISIBLE_DEACTIVATED_ALT_ID:
			tile_data.modulate = Color(0.5, 0.5, 0.5, 0.0)  # Grayed and transparent


## Static factory method to create a ConfigurableTileSet from configs
static func create_from_configs(configs: Array) -> ConfigurableTileSet:
	var tileset := ConfigurableTileSet.new()
	tileset.init(configs)
	tileset.uv_clipping = true
	return tileset
