extends Node2D
class_name LevelEncoder

var chunk_size = Vector2i(10, 10)

func encode(level_layers: Node2D, bg: Node2D, level_manager: LevelManager) -> Dictionary:
	var level = {
		"title": LevelEditor.current_level_name,
		"description": LevelEditor.current_level_description,
		"map_layers": [],
		"art_layers": [],
		"properties": {
			"background": bg.id,
			"fadeColor": bg.fade_color,
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
				"name": group_layer.name,
				"chunks": encode_chunks(group_layer.tile_map_layer),
				"tile_map_rotation": group_layer.tile_map_rotation,
				"z_axis": group_layer.z_axis,
				"anchor": {"x": group_layer.anchor.x, "y": group_layer.anchor.y}
			}
			level.map_layers.push_back(map_layer)
	for group_layer in level_layers.art_layers.get_children():
		if group_layer is ArtLayer:
			var art_layer = {
				"name": group_layer.name,
				"lines": encode_lines(group_layer.lines),
				"stamps": encode_stamps(group_layer.stamps),
				"texts": encode_texts(group_layer.texts),
				"rotation": group_layer.art_rotation,
				"depth": group_layer.depth,
				"alpha": group_layer.alpha,
				"anchor": {"x": group_layer.anchor.x, "y": group_layer.anchor.y}
			}
			level.art_layers.push_back(art_layer)
	return level


func encode_chunks(tile_map_layer: TileMapLayer) -> Array:
	var chunk_map = {}
	var chunks = []
	var used_coords = tile_map_layer.get_used_cells()
	for coords in used_coords:
		var atlas_coords = tile_map_layer.get_cell_atlas_coords(coords)
		var block_id = CoordinateUtils.to_block_id(atlas_coords)
		var block_options = null
		var tile_data = tile_map_layer.get_cell_tile_data(coords)
		if tile_data and tile_data.has_custom_data("tile_options"):
			block_options = tile_data.get_custom_data("tile_options")
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
			var options = []
			data.resize(chunk_size.x * chunk_size.y)
			data.fill(0)
			options.resize(chunk_size.x * chunk_size.y)
			options.fill([])
			chunk = {
				"x": chunk_coords.x * chunk_size.x,
				"y": chunk_coords.y * chunk_size.y,
				"width": chunk_size.x,
				"height": chunk_size.y,
				"data": data,
				"options": options
			}
			chunks.push_back(chunk)
			chunk_map[chunk_name] = chunk
		chunk.data[chunk_data_index] = block_id
		chunk.options[chunk_data_index] = block_options
	return chunks


func encode_lines(node: Node2D) -> Array:
	var lines = []
	
	for line: Line2D in node.get_children():
		if line is Line2D:
			var pointObjects = []
			for point in line.points:
				pointObjects.push_back({"x": point.x, "y": point.y})
			var lineData = {
				"x": line.position.x,
				"y": line.position.y,
				"points": pointObjects.slice(1, len(pointObjects)), # the first point should always be 0,0, we can leave it out
				"color": line.default_color,
				"thickness": line.width,
				"material": line.material
			}
			lines.push_back(lineData)
	return lines


func encode_stamps(node: Node2D) -> Array:
	var stamps = []
	for stamp: Node2D in node.get_children():
		var stampData = {
			"id": stamp.stamp_id,
			"position": {"x": stamp.stamp_position.x, "y": stamp.stamp_position.y},
			"scale": {"x": stamp.stamp_scale.x, "y": stamp.stamp_scale.y},
			"rotation": stamp.stamp_rotation
		}
		stamps.push_back(stampData)
	return stamps


func encode_texts(node: Node2D) -> Array:
	var texts = []
	for text: Node2D in node.get_children():
		var textData = {
			"text": text.text_string,
			"font": text.text_font,
			"font_size": text.text_font_size,
			"scale": {"x": text.text_scale.x, "y": text.text_scale.y},
			"position": {"x": text.text_position.x, "y": text.text_position.y},
			"rotation": text.text_rotation,
			"color": text.text_color
		}
		texts.push_back(textData)
	return texts
