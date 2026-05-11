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
var health_dict = {}


func init(config: Dictionary) -> void:
	#print("Block::init ", config)
	_config = config
	settings.import_settings(config.settings)


func on(event: String, body: PhysicsBody2D, tile_map_layer: TileMapLayer, coords: Vector2i, normal: Vector2 = Vector2.ZERO) -> void:
	#print("Block::on " + event)
	var current_sides = settings.get_sides()
	if event not in current_sides:
		return
			
	if BlockBehaviors.has_method(current_sides[event].type):
		BlockBehaviors.call(current_sides[event].type, body, tile_map_layer, coords, self, current_sides[event].params, normal)
	if event == "bump":
		TileEffects.bump(body, tile_map_layer, coords)
		Jukebox.play_sound("bump")


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


### Shatters the block
#func shatter(tile_map_layer: TileMapLayer, coords: Vector2i):
	#TileEffects.shatter(tile_map_layer, coords, 10)
	#Jukebox.play_sound("shatterblock")
#
#
## Crumbles the block by how fast the node is moving
#func crumble(node: Node2D, tile_map_layer: TileMapLayer, coords: Vector2i, params: Dictionary):
	# oh shit, math
	# we want the velocity of the player, but only the % of the velocity that is moving towards the block
	# this is vector projection
	#if "movement" not in node:
		#return
	#var key = get_slug(tile_map_layer, coords)
	#var magnitude = node.movement.last_velocity.length()
	#var direction = node.movement.last_collision_normal
	#var dot = node.movement.last_velocity.dot(direction)
	#var projection = (dot / direction.length_squared()) * direction
	#var magnitude_towards = projection.length()
	#var damage = (magnitude_towards * params.get("damage_ratio", 0.03)) - params.get("armor", 10.0)
	#var pieces = 1
	#if damage > 0:
		#var tile_health = health_dict.get(key, params.get("health", 100.0))
		#tile_health -= damage
		#health_dict[key] = tile_health
		#print(damage)
		#if tile_health <= 0:
			#TileEffects.shatter(tile_map_layer, coords, 10)
			#health_dict.remove(key)
		#else:
			#while damage > 0:
				#damage -= 9
				#pieces += 1
			#TileEffects.crumble(tile_map_layer, coords, pieces)
	# print({
	#	"key": key,
	#	"player_velocity" :player.last_velocity,
	#	"magnitude": magnitude,
	#	"direction": direction,
	#	"dot": dot,
	#	"projection": projection,
	#	"magnitude_towards": magnitude_towards
	#})
#
#
#func finish(node: Node2D) -> void:
	#if "movement" not in node or "finished" not in node.movement:
		#return
	#if !node.movement.finished:
		#node.movement.finished = true
		#Jukebox.play_sound("victory")
