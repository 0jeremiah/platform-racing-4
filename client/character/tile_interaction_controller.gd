class_name TileInteractionController
## Manages character interactions with tiles in the game world.
## Handles collision detection, tile effects, and character depth management.

const OUT_OF_BOUNDS_BLOCK_COUNT = 15

var game: Node2D
var low_area: Area2D
var high_area: Area2D
var last_safe_position: Vector2 = Vector2(0, 0)
var last_safe_layer: Node
var last_collision: KinematicCollision2D
var character_depth: = 10


func _init(_character: Character, low_area_node: Area2D, high_area_node: Area2D):
	low_area = low_area_node
	high_area = high_area_node
	last_safe_position = Vector2(0, 0)
	var solid_layer = Helpers.to_bitmask_32((10 * 2) - 1)
	var vapor_layer = Helpers.to_bitmask_32(10 * 2)
	_character.collision_layer = solid_layer
	_character.collision_mask = solid_layer
	low_area.collision_layer = vapor_layer
	low_area.collision_mask = solid_layer | vapor_layer
	high_area.collision_mask = solid_layer


func should_crouch(character: Character) -> bool:
	if !character.is_on_floor():
		return false
	var tiles_overlapping: Array = get_tiles_overlapping_area(high_area)
	for tile_data in tiles_overlapping:
		if tile_data.tile_map_layer.is_solid(tile_data.coords):
			return true
	return false


func interact_with_incoporeal_tiles(character: Character):
	character.movement.swimming = false
	var tiles_overlapping: Array = get_tiles_overlapping_area(low_area)
	
	if tiles_overlapping.size() == 0:
		return
	
	var overlapping_tile = tiles_overlapping[0]
	if overlapping_tile.tile_map_layer.is_liquid(overlapping_tile.coords):
		character.movement.swimming = true


func interact_with_solid_tiles(character: Character, lighting: LightbreakController) -> bool:
	var collision: KinematicCollision2D = character.get_last_slide_collision()
	last_collision = collision
	if !collision:
		return false
		
	var tile_map_layer = collision.get_collider()
	if not (tile_map_layer is ConfigurableTileMapLayer):
		return false

	var normal = collision.get_normal().rotated(-character.rotation)
	var rid = collision.get_collider_rid()
	var coords = tile_map_layer.get_coords_for_body_rid(rid)
	character.movement.last_collision_normal = normal
	
	# Blow up tiles when sun lightbreaking
	if lighting.direction.length() > 0 and lighting.fire_power > 0:
		TileEffects.shatter(tile_map_layer, coords, 10)
		lighting.fire_power -= 1
		return false
	else:
		return true


func check_out_of_bounds(character: Character) -> void:
	if not Game.game:
		return
	var current_layer = Game.game.get_current_player_layer()
	if not current_layer:
		return
	var map_used_rect = Game.game.get_total_used_rect_in_z_axis(character_depth)
	
	var min_x = map_used_rect.position.x - OUT_OF_BOUNDS_BLOCK_COUNT
	var max_x = map_used_rect.position.x + map_used_rect.size.x + OUT_OF_BOUNDS_BLOCK_COUNT
	var min_y = map_used_rect.position.y - OUT_OF_BOUNDS_BLOCK_COUNT
	var max_y = map_used_rect.position.y + map_used_rect.size.y + OUT_OF_BOUNDS_BLOCK_COUNT
	
	var player_x_normalised = character.position.x / Settings.tile_size.x
	var player_y_normalised = character.position.y / Settings.tile_size.y

	if player_x_normalised < min_x or player_x_normalised > max_x or \
	   player_y_normalised > max_y:
		if (last_safe_layer != null and (last_safe_layer.players != character.get_parent())):
			character.get_parent().remove_child(character)
			last_safe_layer.players.add_child(character)
			set_depth(last_safe_layer.z_axis)
			Game.game.set_current_player_layer(last_safe_layer.name)
		character.position.x = last_safe_position.x
		character.position.y = last_safe_position.y
		character.movement.current_velocity = Vector2(0, 0)


func get_tiles_overlapping_area(area: Area2D) -> Array:
	var tiles = []
	var bodies: Array = area.get_overlapping_bodies()
	for tile_map_layer in bodies:
		if !(tile_map_layer is TileMapLayer):
			continue
		var coords = tile_map_layer.local_to_map(tile_map_layer.to_local(area.to_global(Vector2.ZERO)))
		var block_id = tile_map_layer.get_block(coords).id
		if block_id != "":
			tiles.push_back({
				"tile_map_layer": tile_map_layer,
				"coords": coords,
				"block_id": block_id
			})
	return tiles
	

func is_in_solid(character: Character) -> bool:
	var tiles_overlapping: Array = get_tiles_overlapping_area(low_area)
	for tile in tiles_overlapping:
		if tile.tile_map_layer.is_solid(tile.coords):
			return true
	return false


func set_depth(depth: int) -> void:
	character_depth = depth


func get_depth() -> float:
	return character_depth / 10.0
