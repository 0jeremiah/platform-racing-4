class_name TileInteractionController
## Manages character interactions with tiles in the game world.
## Handles collision detection, tile effects, and character depth management.

const OUT_OF_BOUNDS_BLOCK_COUNT = 15

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
	var solid_layer = BlockManager._tile_set.get_physics_layer_collision_layer(BlockManager.solid_layer_id)
	var vapor_layer = BlockManager._tile_set.get_physics_layer_collision_layer(BlockManager.non_solid_layer_id)
	_character.collision_layer = solid_layer
	_character.collision_mask = solid_layer
	low_area.collision_layer = vapor_layer
	low_area.collision_mask = solid_layer | vapor_layer
	high_area.collision_mask = solid_layer


func should_crouch(character: Character) -> bool:
	var crouch = false
	if !character.is_on_floor():
		return false
	var tiles_overlapping: Array = get_tiles_overlapping_area(high_area)
	for tile_data in tiles_overlapping:
		if tile_data.tile_map_layer.is_solid(tile_data.coords):
			var tile_info = tile_data.tile_map_layer.get_block(tile_data.coords)
			if !tile_info.node:
				continue
			var direction = (character.global_position - tile_info.node.global_position).normalized()
			var normal := Vector2.ZERO
			if abs(direction.x) > abs(direction.y):
				normal = Vector2(sign(direction.x), 0)
			else:
				normal = Vector2(0, sign(direction.y))
			normal.rotated(-character.rotation).normalized()
			if abs(normal.x) > abs(normal.y):
				if normal.x > 0:
					if tile_info.settings.left.type != ConfigurableBlockSideSettings.INACTIVE:
						crouch = true
				else:
					if tile_info.settings.right.type != ConfigurableBlockSideSettings.INACTIVE:
						crouch = true
			else:
				if normal.y > 0:
					if tile_info.settings.bottom.type != ConfigurableBlockSideSettings.INACTIVE:
						crouch = true
				else:
					if tile_info.settings.top.type != ConfigurableBlockSideSettings.INACTIVE:
						crouch = true
	return crouch


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
	var collider = collision.get_collider()
	if !collider:
		return false
	var parent = collider.get_parent()
	if not (parent is ConfigurableTileMapLayer):
		return false

	var normal = collision.get_normal().rotated(-character.rotation)
	var coords: Vector2i
	if collider is BlockScene:
		collider.get_coords()
	else:
		var rid = collision.get_collider_rid()
		coords = parent.get_coords_for_body_rid(rid)
	character.movement.last_collision_normal = normal
	
	# Blow up tiles when sun lightbreaking
	if lighting.direction.length() > 0 and lighting.fire_power > 0:
		TileEffects.shatter(parent, coords, 10)
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
	var rotated_vectors = [Vector2(map_used_rect.position.x, map_used_rect.position.y).rotated(character.rotation),
	Vector2(map_used_rect.position.x + map_used_rect.size.x, map_used_rect.position.y).rotated(character.rotation),
	Vector2(map_used_rect.position.x, map_used_rect.position.y + map_used_rect.size.y).rotated(character.rotation),
	Vector2(map_used_rect.position.x + map_used_rect.size.x, map_used_rect.position.y + map_used_rect.size.y).rotated(character.rotation)]
	var x_points = []
	var y_points = []
	for rotated_vector in rotated_vectors:
		x_points.append(rotated_vector.x)
		y_points.append(rotated_vector.y)
	x_points.sort()
	y_points.sort()
	#return Rect2i(int(x_points[0]), int(y_points[0]), int(abs(x_points[0] - x_points[3])), int(abs(y_points[0] - y_points[3])))
	
	var min_x = map_used_rect.position.x - OUT_OF_BOUNDS_BLOCK_COUNT
	var max_x = map_used_rect.position.x + map_used_rect.size.x + OUT_OF_BOUNDS_BLOCK_COUNT
	var min_y = map_used_rect.position.y - OUT_OF_BOUNDS_BLOCK_COUNT
	var max_y = map_used_rect.position.y + map_used_rect.size.y + OUT_OF_BOUNDS_BLOCK_COUNT
	
	var player_x_normalised = character.position.x / Settings.tile_size.x
	var player_y_normalised = character.position.y / Settings.tile_size.y

	if player_x_normalised < min_x or player_x_normalised > max_x or\
	(player_y_normalised < min_y and character.rotation != 0) or player_y_normalised > max_y:
		if (last_safe_layer != null and (self not in last_safe_layer.players.get_children())):
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
	for body in bodies:
		var parent = body.get_parent()
		if !(parent is ConfigurableTileMapLayer):
			continue
		var coords: Vector2i
		if body is BlockScene:
			coords = body.get_coords()
		else:
			coords = parent.local_to_map(parent.to_local(area.to_global(Vector2.ZERO)))
		var block_id = parent.get_block(coords).id
		if block_id != "":
			tiles.push_back({
				"tile_map_layer": parent,
				"coords": coords,
				"block_id": block_id
			})
	return tiles


func maybe_mark_safe_block(character: Character, tile_map_layer: ConfigurableTileMapLayer, coords: Vector2i):
	if tile_map_layer.is_safe(coords) and tile_map_layer.name.contains("gear") == false:
		var centre_safe_block = Vector2(coords.x * Settings.tile_size_half.x * 2 + Settings.tile_size_half.x,
		coords.y * Settings.tile_size_half.y * 2 + Settings.tile_size_half.y).rotated(tile_map_layer.global_rotation)
		last_safe_position = centre_safe_block - (Vector2(0, (float(Settings.tile_size.y) / 2))).rotated(tile_map_layer.global_rotation + character.rotation)
		last_safe_layer = tile_map_layer.map_layer


func is_in_solid() -> bool:
	var tiles_overlapping: Array = get_tiles_overlapping_area(low_area)
	for tile in tiles_overlapping:
		if tile.tile_map_layer.is_solid(tile.coords):
			return true
	return false


func inside_solid_blocks_check(character: Character):
	var tiles_overlapping: Array = get_tiles_overlapping_area(low_area)
	var tiles = []
	for tile in tiles_overlapping:
		if tile.tile_map_layer.is_solid(tile.coords):
			var block_scene = tile.tile_map_layer.get_block(tile.coords).node
			if block_scene and block_scene.active:
				tiles.append(block_scene)
	var collision_exceptions = character.get_collision_exceptions()
	for collision_exception in collision_exceptions:
		if collision_exception not in tiles:
			character.remove_collision_exception_with(collision_exception)
	for tile in tiles:
		if tile not in collision_exceptions:
			character.add_collision_exception_with(tile)


func set_depth(depth: int) -> void:
	character_depth = depth


func get_depth() -> float:
	return character_depth / 10.0
