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

var id: int = 1
var settings = ConfigurableBlockSettings.new()
var _config: Dictionary


func init(config: Dictionary) -> void:
	#print("Block::init ", config)
	_config = config
	settings.import_settings(_config.settings)


func on(event: String, body: PhysicsBody2D, tile_map_layer: TileMapLayer, coords: Vector2i, normal: Vector2 = Vector2.ZERO) -> void:
	#print("Block::on " + event)
	var current_sides = settings.get_sides()
	if event not in current_sides:
		return
	if BlockBehaviors.has_method(current_sides[event].type):
		BlockBehaviors.call(current_sides[event].type, body, tile_map_layer, coords, current_sides[event].params, normal)
	if event == "bump":
		#TileEffects.bump(body, tile_map_layer, coords)
		Jukebox.play_sound("bump")


func get_center_position(tile_map_layer: TileMapLayer, coords: Vector2i) -> Vector2:
	return (Vector2(coords * Settings.tile_size) + Vector2(Settings.tile_size_half)).rotated(tile_map_layer.rotation)


func activate(tile_map_layer: TileMapLayer, coords: Vector2i) -> void:
	var atlas_source = tile_map_layer.get_cell_source_id(coords)
	var atlas_coords: Vector2i = tile_map_layer.get_cell_atlas_coords(coords)
	tile_map_layer.set_cell(coords, atlas_source, atlas_coords, ConfigurableBlock.VISIBLE_ALT_ID)


func deactivate(tile_map_layer: TileMapLayer, coords: Vector2i) -> void:
	var atlas_source = tile_map_layer.get_cell_source_id(coords)
	var atlas_coords: Vector2i = tile_map_layer.get_cell_atlas_coords(coords)
	tile_map_layer.set_cell(coords, atlas_source, atlas_coords, ConfigurableBlock.DEACTIVATED_ALT_ID)


func set_visible(tile_map_layer: TileMapLayer, coords: Vector2i, visible: bool) -> void:
	var atlas_source = tile_map_layer.get_cell_source_id(coords)
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
	tile_map_layer.set_cell(coords, atlas_source, atlas_coords, alt_id)


func is_active(tile_map_layer: TileMapLayer, coords: Vector2i) -> bool:
	var alt_id := tile_map_layer.get_cell_alternative_tile(coords)
	return alt_id == ConfigurableBlock.VISIBLE_ALT_ID or alt_id == ConfigurableBlock.INVISIBLE_ALT_ID


func is_visible(tile_map_layer: TileMapLayer, coords: Vector2i) -> bool:
	var alt_id := tile_map_layer.get_cell_alternative_tile(coords)
	return alt_id == ConfigurableBlock.DEACTIVATED_ALT_ID or alt_id == ConfigurableBlock.VISIBLE_ALT_ID
