extends TileMapLayer
class_name ConfigurableTileMapLayer
## TileMapLayer extension that works with ConfigurableBlock system
##
## Provides convenience methods to place tiles by block ID instead of requiring
## knowledge of source IDs and atlas coordinates.


const EGG_ENEMY = preload("res://effects/egg/egg_enemy.tscn")
var map_layer: MapLayer = null
var block_dict = {}


## Converts coords into a name used for storing them into block_dict
func get_block_dict_name(coords: Vector2i) -> String:
	return str(coords.x) + "," + str(coords.y)


## Gets all used coords from block_dict
func get_all_block_coords() -> Array:
	var used_coords = []
	var block_dict_keys = block_dict.keys()
	for block_dict_key in block_dict_keys:
		var used_coord = Array(block_dict_key.split(","))
		if used_coord.size() > 1 and used_coord[0].is_valid_int() and used_coord[1].is_valid_int():
			used_coords.append(Vector2i(int(used_coord[0]), int(used_coord[1])))
	return used_coords


## Gets all coords containing this block id from block_dict
func get_all_block_coords_by_id(block_id: String) -> Array:
	var used_coords = []
	var block_dict_keys = block_dict.keys()
	for block_dict_key in block_dict_keys:
		var used_coord = Array(block_dict_key.split(","))
		if used_coord.size() > 1 and used_coord[0].is_valid_int() and used_coord[1].is_valid_int() and block_dict[block_dict_key].id == block_id:
			used_coords.append(Vector2i(int(used_coord[0]), int(used_coord[1])))
	return used_coords


## Set a cell by block ID instead of atlas coordinates
func add_block(coords: Vector2i, block_id: String, alt_id: int = ConfigurableBlock.VISIBLE_ALT_ID, settings: Dictionary = {}) -> void:
	if block_id == "":
		push_warning("Block ID cannot be blank")
		return
	var tile_info: Dictionary = BlockManager._block_lookup.get(block_id, {})
	if tile_info.is_empty():
		push_warning("Block ID not found: " + block_id)
		return
	var block_dict_name = get_block_dict_name(coords)
	var block_settings = ConfigurableBlockSettings.new()
	block_settings.import_settings(BlockManager._block_lookup[block_id].settings)
	if !settings.is_empty():
		block_settings.import_edited_settings(settings)
	var maybe_block = null
	if block_dict.has(block_dict_name) and block_dict[block_dict_name].node != null:
		maybe_block = block_dict[block_dict_name].node
	elif find_child(block_dict_name) != null:
		maybe_block = find_child(block_dict_name)
	block_dict[block_dict_name] = {"id": block_id, "settings": block_settings, "node": maybe_block}
	if maybe_block:
		maybe_block.init(block_id, block_settings)
	else:
		set_cell(coords, 0, Vector2i(0, 0), tile_info.alternative_tile)


## Get cell block ID from coordinates (reverse lookup)
func get_block(coords: Vector2i) -> Dictionary:
	var block_dict_name = get_block_dict_name(coords)
	if block_dict.has(block_dict_name) and block_dict[block_dict_name].has("id") and block_dict[block_dict_name]["id"] != "":
		var block_settings = null
		var block_node = null
		if block_dict[block_dict_name].has("settings") and block_dict[block_dict_name].settings != null:
			block_settings = block_dict[block_dict_name].settings
		if block_dict[block_dict_name].has("node") and block_dict[block_dict_name].node != null:
			block_node = block_dict[block_dict_name].node
		return {"id": block_dict[block_dict_name]["id"], "settings": block_settings, "node": block_node}
	return {"id": "", "settings": null, "node": null}


func delete_block(coords: Vector2i) -> void:
	var block_dict_name = get_block_dict_name(coords)
	if block_dict.has(block_dict_name):
		block_dict.erase(block_dict_name)
		erase_cell(coords)


func is_solid(coords: Vector2i) -> bool:
	#var block_id = get_block(coords).id
	var block_dict_name = get_block_dict_name(coords)
	if block_dict.has(block_dict_name):
		return block_dict[block_dict_name].settings.matter_type == ConfigurableBlockSettings.SOLID
	#if block_id:
		#return BlockManager._blocks[block_id].settings.matter_type == ConfigurableBlockSettings.SOLID
	return false


func is_liquid(coords: Vector2i) -> bool:
	#var block_id = get_block(coords).id
	var block_dict_name = get_block_dict_name(coords)
	if block_dict.has(block_dict_name):
		return block_dict[block_dict_name].settings.matter_type == ConfigurableBlockSettings.LIQUID
	#if block_id:
		#return BlockManager._blocks[block_id].settings.matter_type == ConfigurableBlockSettings.LIQUID
	return false


func is_safe(coords: Vector2i) -> bool:
	var unsafe_matter_types = [ConfigurableBlockSettings.GAS]
	var unsafe_block_types = [ConfigurableBlockSettings.MOVE]
	var unsafe_block_sides = [ConfigurableBlockSideSettings.MINE, ConfigurableBlockSideSettings.VANISH,
	ConfigurableBlockSideSettings.PUSH, ConfigurableBlockSideSettings.CRUMBLE,
	ConfigurableBlockSideSettings.SAFETY, ConfigurableBlockSideSettings.SHATTER]
	#var block_id = get_block(coords).id
	#if block_id:
	var block_dict_name = get_block_dict_name(coords)
	if block_dict.has(block_dict_name):
		var matter_type_is_safe: bool = block_dict[block_dict_name].settings.matter_type not in unsafe_matter_types
		var block_type_is_safe: bool = block_dict[block_dict_name].settings.matter_type not in unsafe_block_types
		var block_side_types = block_dict[block_dict_name].settings.get_side_types()
		for block_side_type in block_side_types:
			if block_side_type in unsafe_block_sides:
				return false
		return matter_type_is_safe and block_type_is_safe
	return false


func get_block_position_at_local_position(local_position: Vector2):
	return Vector2(local_to_map(local_position)).rotated(rotation)


func get_block_center_position(coords: Vector2i):
	return Vector2(Vector2i(coords * Settings.tile_size) + Vector2i(Settings.tile_size_half)).rotated(rotation)


func get_start_positions() -> Array:
	var start_blocks = []
	for block in BlockManager._blocks:
		var block_instance = BlockManager._blocks[block]
		if block_instance.settings.block_type == ConfigurableBlockSettings.START_POSITION:
			start_blocks.append(block)
	var start_options = []
	for start_block in start_blocks:
		var coord_list = get_all_block_coords_by_id(start_block)
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
		var coord_list = get_all_block_coords_by_id(finish_block)
		for coords in coord_list:
			var block = get_block(coords)
			var reached = true if block and block.settings.can_finish else false
			var start_option = {
				"tile_map_layer": self,
				"coords": coords,
				"reached": reached
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
		var coord_list = get_all_block_coords_by_id(egg)
		for coords in coord_list:
			egg_counter += 1
			var egg_enemy = EGG_ENEMY.instantiate()
			var depth = Helpers.get_depth(map_layer)
			egg_enemy.tile_map_layer = self
			egg_enemy.position = BlockManager._blocks[egg].get_center_position(self, coords)
			egg_enemy.name = "EggEnemy" + str(egg_counter)
			map_layer.enemies.add_child(egg_enemy)
			egg_enemy.set_depth(depth)
			#BlockManager._blocks[egg].deactivate(self, coords)
			#BlockManager._blocks[egg].set_visible(self, coords, false)
			delete_block(coords)


func spawn_gears():
	var non_static_tile_map_layers = map_layer.non_static_tile_map_layers
	var gear_blocks = []
	for block in BlockManager._blocks:
		var block_instance = BlockManager._blocks[block]
		if block_instance.settings.block_type == ConfigurableBlockSettings.GEAR:
			gear_blocks.append(block)
	for gear in gear_blocks:
		var attached_directions = []
		var block_instance = BlockManager._blocks[gear]
		if block_instance.settings.top.type == ConfigurableBlockSideSettings.ATTACH:
			attached_directions.append(Vector2i(0, -1))
		if block_instance.settings.bottom.type == ConfigurableBlockSideSettings.ATTACH:
			attached_directions.append(Vector2i(0, 1))
		if block_instance.settings.left.type == ConfigurableBlockSideSettings.ATTACH:
			attached_directions.append(Vector2i(-1, 0))
		if block_instance.settings.right.type == ConfigurableBlockSideSettings.ATTACH:
			attached_directions.append(Vector2i(1, 0))
		var gear_counter = 0
		var coord_list = get_all_block_coords_by_id(gear)
		for coords in coord_list:
			delete_block(coords)
			gear_counter += 1
			# Create rotation controller
			var rotation_controller = RotationController.new()
			rotation_controller.position = Vector2(coords * Settings.tile_size) + Vector2(Settings.tile_size_half)
			rotation_controller.rotation = rotation
			rotation_controller.target_rotation = rotation
			rotation_controller.name = "GearTile" + str(gear_counter)
			non_static_tile_map_layers.add_child(rotation_controller)
			# Create sub tile_map_layer
			var sub_tile_map_layer = ConfigurableTileMapLayer.new()
			sub_tile_map_layer.tile_set = BlockManager._tile_set
			sub_tile_map_layer.map_layer = map_layer
			sub_tile_map_layer.name = "gear_" + str(coords) + "_configurable_tile_map_layer"
			sub_tile_map_layer.add_block(Vector2i(0, 0), gear)
			sub_tile_map_layer.position = -Settings.tile_size_half # doesn't work, workaround in RotationController
			sub_tile_map_layer.use_kinematic_bodies = true
			sub_tile_map_layer.physics_quadrant_size = 1
			rotation_controller.add_child(sub_tile_map_layer)
			# Transfer tiles connected to the gear into the sub tile_map_layer
			for attached_direction in attached_directions:
				var queue = [coords + attached_direction]
				while(len(queue) > 0):
					var current_coords: Vector2i = queue.pop_back()
					var block_info = get_block(current_coords)
					if block_info.id != "":
						var block_settings = {}
						if block_info.settings != null:
							block_settings = block_info.settings.get_edited_settings()
						delete_block(current_coords)
						sub_tile_map_layer.add_block(current_coords - coords, block_info.id, ConfigurableBlock.VISIBLE_ALT_ID, block_settings)
						queue.append_array(get_surrounding_cells(current_coords))
						# If there is a switch, deactivate rotation by default (probably make it an option in block editor)
						#if (code to check if it can only be moved by presence switch goes here):
							#rotation_controller.enabled = false
							#rotation_controller.tick_ms = 2000


func get_teleport_positions_at_block_id(block_id: String) -> Array:
	if !block_id in BlockManager._blocks and block_id in BlockManager._block_lookup:
		return []
	var teleport_block = BlockManager._blocks[block_id]
	if !teleport_block.settings.has_side_type(ConfigurableBlockSideSettings.TELEPORT):
		return []
	var teleport_positions = []
	var coord_list = get_all_block_coords_by_id(block_id)
	for coords in coord_list:
		var block = get_block(coords)
		var teleport_position = {
			"color": block.settings.teleport_color,
			"tile_map_layer": self,
			"coords": coords,
			"map_layer_name": str(map_layer.name),
		}
		teleport_positions.push_back(teleport_position)
	return teleport_positions

## Trigger block behaviors for a tile collision
func trigger_tile_behaviors(body: PhysicsBody2D, coords: Vector2i, events: Array[String], normal: Vector2 = Vector2.ZERO) -> void:
	var block_id = get_block(coords).id
	if block_id == "":
		return

	var block: ConfigurableBlock = BlockManager._blocks.get(block_id)
	if not block:
		return

	for event in events:
		block.on(event, body, self, coords, normal)
