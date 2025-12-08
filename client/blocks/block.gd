class_name ConfigurableBlock
## Block that is configured via a Dictionary instead of a GDScript class
##
## Allows runtime creation of tiles with custom behaviors defined in JSON or code.

const STATIC := "static"
const SOLID := "solid"
const LIQUID := "liquid"
const GAS := "gas"

const VISIBLE_ALT_ID := 0
const INVISIBLE_ALT_ID := 1
const DEACTIVATED_ALT_ID := 2
const INVISIBLE_DEACTIVATED_ALT_ID := 3

var _config: Dictionary
var _behaviors: Dictionary
var physics_type := STATIC
var matter_type := SOLID
var is_safe: bool = true


func init(config: Dictionary) -> void:
	print("Block::init ", config)
	_config = config
	_behaviors = _config.get("behaviors", {})
	matter_type = _config.get("matter_type", ConfigurableBlock.SOLID)
	physics_type = _config.get("physics_type", "static")
	is_safe = _config.get("is_safe", true)


func on(event: String, body: PhysicsBody2D, tile_map_layer: TileMapLayer, coords: Vector2i) -> void:
	print("Block::on " + event)
	if event not in _behaviors:
		return

	for behavior in _behaviors[event]:
		BlockBehaviors.call(behavior.name, body, tile_map_layer, coords, behavior.params)


func get_center_position(tile_map_layer: TileMapLayer, coords: Vector2i) -> Vector2:
	return (Vector2(coords * Settings.tile_size) + Vector2(Settings.tile_size_half)).rotated(tile_map_layer.rotation)


func deactivate(tile_map_layer: TileMapLayer, coords: Vector2i) -> void:
	var atlas_coords: Vector2i = tile_map_layer.get_cell_atlas_coords(coords)
	tile_map_layer.set_cell(coords, 0, atlas_coords, ConfigurableBlock.DEACTIVATED_ALT_ID)


func set_visible(tile_map_layer: TileMapLayer, coords: Vector2i, visible: bool) -> void:
	var atlas_coords: Vector2i = tile_map_layer.get_cell_atlas_coords(coords)
	var alt_id: int
	if visible:
		if is_active(tile_map_layer, coords):
			alt_id = ConfigurableBlock.VISIBLE_ALT_ID
		else:
			alt_id = ConfigurableBlock.DEACTIVATED_ALT_ID
	else:
		if is_active(tile_map_layer, coords):
			alt_id = ConfigurableBlock.INVISIBLE_ALT_ID
		else:
			alt_id = ConfigurableBlock.INVISIBLE_DEACTIVATED_ALT_ID
	tile_map_layer.set_cell(coords, 0, atlas_coords, alt_id)


func is_active(tile_map_layer: TileMapLayer, coords: Vector2i) -> bool:
	var alt_id := tile_map_layer.get_cell_alternative_tile(coords)
	return alt_id == ConfigurableBlock.VISIBLE_ALT_ID or alt_id == ConfigurableBlock.INVISIBLE_ALT_ID


func is_visible(tile_map_layer: TileMapLayer, coords: Vector2i) -> bool:
	var alt_id := tile_map_layer.get_cell_alternative_tile(coords)
	return alt_id == ConfigurableBlock.DEACTIVATED_ALT_ID or alt_id == ConfigurableBlock.VISIBLE_ALT_ID


func get_slug(tile_map_layer: TileMapLayer, coords: Vector2i) -> String:
	return str(tile_map_layer.get_path()) + "/" + str(coords)
