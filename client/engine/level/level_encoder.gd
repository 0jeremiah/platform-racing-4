extends Node2D
class_name LevelEncoder

var mega_chunk_size = 1000
var chunk_size = Vector2i(10, 10)

func encode(level_layers: Node2D, level_manager: LevelManager) -> Dictionary:
	var level = {
		"title": LevelEditor.current_level_name,
		"description": LevelEditor.current_level_description,
		"map_layers": [],
		"art_layers": [],
		"properties": {
			"background": level_manager.background_id,
			"fadeColor": level_manager.fade_color,
			"music": level_manager.music,
			"level_type": level_manager.level_type,
			"time": level_manager.time,
			"gravity": level_manager.gravity,
			"password": level_manager.password,
			"sfchm_chance": level_manager.sfchm_chance,
			"wind_chance": level_manager.wind_chance,
			"snow_chance": level_manager.snow_chance,
			"alien_chance": level_manager.alien_chance,
			"items": level_manager.items,
			"game_config_overrides": GameConfig.export_overrides()
		}
	}
	for group_layer in level_layers.map_layers.get_children():
		if group_layer is MapLayer:
			var map_layer = {
				"name": group_layer.layer_name,
				"chunks": encode_chunks(group_layer.tile_map_layer),
				"tile_map_rotation": group_layer.tile_map_rotation,
				"z_axis": group_layer.z_axis,
				"anchor": {"x": group_layer.anchor.x, "y": group_layer.anchor.y},
				"z_index": group_layer.layer_z_index
			}
			level.map_layers.push_back(map_layer)
	for group_layer in level_layers.art_layers.get_children():
		if group_layer is ArtLayer:
			var art_layer = {
				"name": group_layer.layer_name,
				"lines": GeneralEncoder.encode_lines(group_layer.lines),
				"stamps": GeneralEncoder.encode_stamps(group_layer.stamps),
				"texts": GeneralEncoder.encode_texts(group_layer.texts),
				"rotation": group_layer.art_rotation,
				"z_axis": group_layer.z_axis,
				"depth": group_layer.depth,
				"alpha": group_layer.alpha,
				"anchor": {"x": group_layer.anchor.x, "y": group_layer.anchor.y},
				"z_index": group_layer.layer_z_index
			}
			level.art_layers.push_back(art_layer)
	return level


func encode_chunks(configurable_tile_map_layer: ConfigurableTileMapLayer) -> Array:
	var chunk_map = {}
	var chunks = []
	var used_coords = configurable_tile_map_layer.get_used_cells()
	for coords in used_coords:
		#var atlas_coords = tile_map_layer.get_cell_atlas_coords(coords)
		var block_id = configurable_tile_map_layer.get_cell_block_id(coords)
		var block_settings = null
		var chunk_coords: Vector2i = Vector2i((Vector2(coords) / Vector2(chunk_size)).floor())
		var chunk_data_coords = coords - (chunk_coords * chunk_size)
		var chunk_name = str(chunk_coords.x) + "," + str(chunk_coords.y)
		var chunk_data_index = (chunk_data_coords.y * chunk_size.x) + chunk_data_coords.x
		var existing_chunk = chunk_map.get(chunk_name)
		var chunk: Dictionary
		if existing_chunk:
			chunk = existing_chunk
		else:
			var data = []
			#var settings = {}
			data.resize(chunk_size.x * chunk_size.y)
			data.fill(0)
			chunk = {
				"x": chunk_coords.x * chunk_size.x,
				"y": chunk_coords.y * chunk_size.y,
				"width": chunk_size.x,
				"height": chunk_size.y,
				"data": data,
				#"settings": {}
			}
			chunks.push_back(chunk)
			chunk_map[chunk_name] = chunk
		chunk.data[chunk_data_index] = {"id": block_id, "settings": block_settings}
		#chunk.options[chunk_data_index] = block_options
	return chunks


func new_encode(level_layers: Node2D, level_manager: LevelManager) -> Dictionary:
	var level = {
		"title": LevelEditor.current_level_name,
		"description": LevelEditor.current_level_description,
		"map_layers": [],
		"art_layers": [],
		"properties": {
			"background": level_manager.background_id,
			"fadeColor": level_manager.fade_color,
			"music": level_manager.music,
			"level_type": level_manager.level_type,
			"time": level_manager.time,
			"gravity": level_manager.gravity,
			"password": level_manager.password,
			"sfchm_chance": level_manager.sfchm_chance,
			"wind_chance": level_manager.wind_chance,
			"snow_chance": level_manager.snow_chance,
			"alien_chance": level_manager.alien_chance,
			"items": level_manager.items,
			"game_config_overrides": GameConfig.export_overrides()
		}
	}
	for group_layer in level_layers.map_layers.get_children():
		if group_layer is MapLayer:
			var map_layer = {
				"name": group_layer.layer_name,
				"chunks": new_encode_chunks(group_layer.tile_map_layer),
				"tile_map_rotation": group_layer.tile_map_rotation,
				"z_axis": group_layer.z_axis,
				"anchor": {"x": group_layer.anchor.x, "y": group_layer.anchor.y},
				"z_index": group_layer.layer_z_index
			}
			level.map_layers.push_back(map_layer)
	for group_layer in level_layers.art_layers.get_children():
		if group_layer is ArtLayer:
			var art_layer = {
				"name": group_layer.layer_name,
				"lines": GeneralEncoder.new_encode_lines(group_layer.lines),
				"stamps": GeneralEncoder.new_encode_stamps(group_layer.stamps),
				"texts": GeneralEncoder.new_encode_texts(group_layer.texts),
				"rotation": group_layer.art_rotation,
				"z_axis": group_layer.z_axis,
				"depth": group_layer.depth,
				"alpha": group_layer.alpha,
				"anchor": {"x": group_layer.anchor.x, "y": group_layer.anchor.y},
				"z_index": group_layer.layer_z_index
			}
			level.art_layers.push_back(art_layer)
	return level


func new_encode_chunks(configurable_tile_map_layer: ConfigurableTileMapLayer) -> String:
	var save_string = ""
	var chunk_map = {}
	var chunks = []
	var used_coords = configurable_tile_map_layer.get_used_cells()
	var compat_used_coords = []
	# seems godot eventually makes chunks null if the chunks array get too big
	# let's limit megachunks to 1000 chunks and save them as string instead to try to combat this
	var array_counter = 0
	if used_coords.size() > mega_chunk_size:
		while mega_chunk_size * array_counter < used_coords.size():
			compat_used_coords.append(used_coords.slice(mega_chunk_size * array_counter, mega_chunk_size * (array_counter + 1)))
			array_counter += 1
	else:
		compat_used_coords = [used_coords]
	for compat_coords in compat_used_coords:
		chunks = []
		chunk_map = {}
		for coords in compat_coords:
			#var atlas_coords = tile_map_layer.get_cell_atlas_coords(coords)
			var block_id = configurable_tile_map_layer.get_cell_block_id(coords)
			var block_settings = null
			var chunk_coords: Vector2i = Vector2i((Vector2(coords) / Vector2(chunk_size)).floor())
			var chunk_data_coords = coords - (chunk_coords * chunk_size)
			var chunk_name = str(chunk_coords.x) + "," + str(chunk_coords.y)
			var chunk_data_index = (chunk_data_coords.y * chunk_size.x) + chunk_data_coords.x
			var existing_chunk = chunk_map.get(chunk_name)
			var chunk: Dictionary
			if existing_chunk:
				chunk = existing_chunk
			else:
				var data = []
				#var settings = {}
				data.resize(chunk_size.x * chunk_size.y)
				data.fill(0)
				chunk = {
					"x": chunk_coords.x * chunk_size.x,
					"y": chunk_coords.y * chunk_size.y,
					"width": chunk_size.x,
					"height": chunk_size.y,
					"data": data,
					#"settings": {}
				}
				chunks.push_back(chunk)
				chunk_map[chunk_name] = chunk
			chunk.data[chunk_data_index] = {"id": block_id, "settings": block_settings}
			#chunk.options[chunk_data_index] = block_options
		#mega_chunks[mega_chunk_name] = chunks
		if save_string != "":
			save_string = save_string + "`" + JSON.stringify(chunks)
		else:
			save_string = save_string + JSON.stringify(chunks)
	return save_string
