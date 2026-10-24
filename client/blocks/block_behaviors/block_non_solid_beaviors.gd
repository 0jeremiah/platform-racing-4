extends Node
class_name NonSolidBlockBehaviors
## Tile behaviors for non-solid blocks (water, lightbreak, etc.)


# activates the node's lightbreak if they have it
func lightbreaker(node: Node2D, tile_map_layer: ConfigurableTileMapLayer, coords: Vector2i, params: Dictionary, _normal: Vector2 = Vector2.ZERO) -> void:
	if "lightbreak" not in node or "movement" not in node:
		return
	# avoid drawing the player into the same light again too soon
	if node.lightbreak.src_tile == coords:
		return
	var block_info = tile_map_layer.get_block(coords)
	if block_info.settings == null:
		return
	# draw the player into the center of the light
	var global_pos = tile_map_layer.to_global((coords * Settings.tile_size) + Settings.tile_size_half)
	var game_pos = node.get_parent().to_local(global_pos)
	var dist = game_pos - node.position
	var target_velocity = dist * 3
	node.movement.current_velocity = target_velocity
	node.light.color = block_info.settings.light_color
	node.lightbreak.direction = Vector2.ZERO
	node.lightbreak.windup += node.get_physics_process_delta_time() * 2
	node.movement.is_crouching = true
	
	# get into the lightbreak faster if you release dir keys and hit the direction you want
	if node.control_vector.length() == 0:
		node.lightbreak.input_primed = true
	if node.control_vector.length() != 0 and node.lightbreak.input_primed:
		start_lightbreak(node, coords, params.get("lightbreak_type", "firefly"))
		return
	
	# at the light timeout, either go in the direction that is being pressed or drop out
	if node.lightbreak.windup >= 1:
		if node.control_vector.length() != 0:
			start_lightbreak(node, coords, params.get("lightbreak_type", "firefly"))
		else:
			node.lightbreak.end_lightbreak()
			node.lightbreak.src_tile = coords


func start_lightbreak(node: Node2D, coords: Vector2i, lightbreak_type: String) -> void:
	node.lightbreak.direction = Vector2(node.control_vector)
	node.lightbreak.src_tile = coords
	node.lightbreak.input_primed = false
	node.lightbreak.windup = 0.1
	node.lightbreak.type = lightbreak_type
	if node.lightbreak.type == "sun":
		node.lightbreak.fire_power += 1
	elif node.lightbreak.type == "moon":
		node.lightbreak.moon_timer = 0.05


# activates a block when touched
func switch(node: Node2D, tile_map_layer: ConfigurableTileMapLayer, coords: Vector2i, params: Dictionary, normal: Vector2 = Vector2.ZERO) -> void:
	var block_info = tile_map_layer.get_block(coords)
	var limit_activate_range = params.get("limit_activate_range", false)
	var activate_range = params.get("activate_range", Vector2i(10, 10))
	var activate_list = params.get("activate_list", {"settings": [], "side_settings": [], "blocks": []})
	if block_info.settings != null:
		limit_activate_range = block_info.settings.limit_activate_range
		activate_range = Vector2i(block_info.settings.activate_range.x, block_info.settings.activate_range.y)
		if activate_list.settings.has(ConfigurableBlockSettings.GEAR):
			activate_gears(node, tile_map_layer, coords, params, normal)
		if activate_list.side_settings.has(ConfigurableBlockSideSettings.SHATTER):
			activate_blocks(Game.game.level_manager.brick_blocks, ConfigurableBlockSideSettings.SHATTER, node, tile_map_layer, coords, params, normal)
		if activate_list.side_settings.has(ConfigurableBlockSideSettings.MINE):
			activate_blocks(Game.game.level_manager.mine_blocks, ConfigurableBlockSideSettings.MINE, node, tile_map_layer, coords, params, normal)
		if activate_list.side_settings.has(ConfigurableBlockSideSettings.CRUMBLE):
			activate_blocks(Game.game.level_manager.crumble_blocks, ConfigurableBlockSideSettings.CRUMBLE, node, tile_map_layer, coords, params, normal)
		if activate_list.side_settings.has(ConfigurableBlockSideSettings.VANISH):
			activate_blocks(Game.game.level_manager.vanish_blocks, ConfigurableBlockSideSettings.VANISH, node, tile_map_layer, coords, params, normal)
		if activate_list.side_settings.has(ConfigurableBlockSideSettings.APPEAR):
			activate_blocks(Game.game.level_manager.appear_blocks, ConfigurableBlockSideSettings.APPEAR, node, tile_map_layer, coords, params, normal)
		#for setting in activate_list.settings:
			#var setting_coords = tile_map_layer.get_all_block_coords_containing_block_type(setting)
			#if limit_activate_range:
				#setting_coords.filter(func(coord): return coord >= (coords - activate_range) and coord <= (coords + activate_range))
			#for setting_coord in setting_coords:
				#var activatable_block_info = tile_map_layer.get_block(setting_coord)
				#if activatable_block_info.settings != null and activatable_block_info.settings.block_type == ConfigurableBlockSettings.GEAR and tile_map_layer.get_parent() is RotationController:
					#tile_map_layer.get_parent().enabled = true
		#for side_setting in activate_list.side_settings:
			#var side_setting_coords = tile_map_layer.get_all_block_coords_containing_side_type(side_setting)
			#if limit_activate_range:
				#side_setting_coords.filter(func(coord): return coord >= (coords - activate_range) and coord <= (coords + activate_range))
			#for side_setting_coord in side_setting_coords:
				#var activatable_block_info = tile_map_layer.get_block(side_setting_coord)
				#var sides = activatable_block_info.settings.get_sides()
				#for side in sides:
					#var current_block_info = tile_map_layer.get_block(side_setting_coord)
					#if current_block_info.id == "" and current_block_info.settings == null and current_block_info.node == null:
						#break
					#tile_map_layer.trigger_tile_behaviors(node, coords, [side], normal)


func activate_gears(_node: Node2D, tile_map_layer: ConfigurableTileMapLayer, coords: Vector2i, params: Dictionary, _normal: Vector2 = Vector2.ZERO):
	var limit_activate_range = params.get("limit_activate_range", false)
	var activate_range = params.get("activate_range", Vector2i(10, 10))
	var gear_blocks = Game.game.level_manager.gear_blocks
	if limit_activate_range:
		gear_blocks.filter(func(gear_block): return gear_block.coords >= (coords - activate_range) and gear_block.coords <= (coords + activate_range))
	for gear_block in gear_blocks:
		var activatable_block_info = tile_map_layer.get_block(gear_block.coords)
		if activatable_block_info.settings != null and activatable_block_info.settings.block_type == ConfigurableBlockSettings.GEAR and tile_map_layer.get_parent() is RotationController:
			tile_map_layer.get_parent().enabled = true


func find_sides(settings: ConfigurableBlockSettings, side_setting: String) -> Array[String]:
	var sides = settings.get_sides()
	var found_sides: Array[String]
	for side in sides:
		if sides[side].type == side_setting:
			found_sides.append(side)
	return found_sides


func activate_blocks(block_array: Array, side_setting: String, node: Node2D, tile_map_layer: ConfigurableTileMapLayer, coords: Vector2i, _params: Dictionary, normal: Vector2 = Vector2.ZERO):
	var current_block_array = block_array
	var block_info = tile_map_layer.get_block(coords)
	if block_info.settings != null:
		var limit_activate_range = block_info.settings.limit_activate_range
		var activate_range = Vector2i(block_info.settings.activate_range.x, block_info.settings.activate_range.y)
		if limit_activate_range:
			current_block_array = block_array.filter(func(block): return block.tile_map_layer == tile_map_layer and Rect2i(coords - activate_range, (activate_range * 2) + Vector2i(1, 1)).has_point(block.coords))
		for block in current_block_array:
			var activatable_block_info = block.tile_map_layer.get_block(block.coords)
			if activatable_block_info.settings != null:
				var sides = find_sides(activatable_block_info.settings, side_setting)
				if !sides.is_empty():
					block.tile_map_layer.trigger_tile_behaviors(node, block.coords, sides, normal)


# Makes the node swim
func water(node: Node2D, _tile_map_layer: ConfigurableTileMapLayer, _coords: Vector2i, params: Dictionary, _normal: Vector2 = Vector2.ZERO):
	if "movement" in node:
		node.movement.swimming = true
		#node.movement.liquid_friction = params.get("liquid_friction", 2.0)
