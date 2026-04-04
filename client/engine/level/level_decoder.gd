extends Node2D
class_name LevelDecoder

signal level_event


func decode(level: Dictionary, level_layers: LevelLayers) -> void:
	GameConfig.clear_overrides()
	var properties = level.get("properties", {})
	print("LevelDecoder::decode: ", properties)
	# Emit background change event
	emit_signal("control_event", {
		"type": EditorEvents.SET_BACKGROUND,
		"bg": properties.get("background", ""),
		"fade_color": properties.get("fadeColor", "FFFFFF")
	})
	# Emit music change event
	emit_signal("control_event", {
		"type": EditorEvents.SET_MUSIC,
		"music": properties.get("music", "random")
	})
	# Emit time change event
	emit_signal("control_event", {
		"type": EditorEvents.SET_TIME,
		"time": properties.get("time", 120)
	})
	# Emit gravity change event
	emit_signal("control_event", {
		"type": EditorEvents.SET_GRAVITY,
		"gravity": properties.get("gravity", 1.0)
	})
	# Emit password change event
	emit_signal("control_event", {
		"type": EditorEvents.SET_PASSWORD,
		"password": properties.get("password", "")
	})
	# Emit sfchm change event
	emit_signal("control_event", {
		"type": EditorEvents.SET_SFCHM_CHANCE,
		"sfchm": properties.get("sfchm", 0)
	})
	# Emit wind change event
	emit_signal("control_event", {
		"type": EditorEvents.SET_WIND_CHANCE,
		"wind": properties.get("wind", 0)
	})
	# Emit snow change event
	emit_signal("control_event", {
		"type": EditorEvents.SET_SNOW_CHANCE,
		"snow": properties.get("snow", 0)
	})
	# Emit alien change event
	emit_signal("control_event", {
		"type": EditorEvents.SET_ALIEN_CHANCE,
		"alien": properties.get("alien", 0)
	})
	# Emit items change event
	emit_signal("control_event", {
		"type": EditorEvents.SET_ITEMS,
		"items": properties.get("items", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14])
	})
	
	# checks for any game config overrides and imports them if they exist
	if properties.has("game_config_overrides"):
		GameConfig.import_overrides(properties.game_config_overrides)
	
	# Failsafe for levels that don't have map_layers or art_layers.
	if level.has("layers"):
		var layers = level.get("layers", [])
		if !layers.is_empty():
			for encoded_layer in layers:
				var chunks = encoded_layer.get("chunks", [])
				if !chunks.is_empty():
					# Emit add block layer event
					emit_signal("level_event", {
						"type": EditorEvents.ADD_MAP_LAYER,
						"name": encoded_layer.name,
						"tile_map_rotation": encoded_layer.get("rotation", 0),
						"z_axis": encoded_layer.get("depth", 10),
						"anchor": {"x": 0, "y": 0}
					})
					if encoded_layer.get("chunks"):
						decode_chunks(encoded_layer.name, encoded_layer.chunks)
			for encoded_layer in layers:
				var lines = encoded_layer.get("lines", [])
				var texts = encoded_layer.get("texts", [])
				if !lines.is_empty() or !texts.is_empty():
					# Emit add art layer event
					emit_signal("level_event", {
						"type": EditorEvents.ADD_ART_LAYER,
						"name": encoded_layer.name,
						"art_scale": encoded_layer.get("scale", 1.0),
						"art_rotation": encoded_layer.get("rotation", 0),
						"depth": encoded_layer.get("depth", 10),
						"z_axis": encoded_layer.get("depth", 10),
						"alpha": 100,
						"anchor": {"x": 0, "y": 0}
					})
					if encoded_layer.get("lines"):
						GeneralDecoder.decode_lines(encoded_layer.name, encoded_layer.lines)
					if encoded_layer.get("usertextboxobjects"):
						GeneralDecoder.decode_texts(encoded_layer.name, encoded_layer.usertextboxobjects)
		level.get_or_add("map_layers", [])
		level.get_or_add("art_layers", [])
		var level_map_layers = level.get("map_layers", [])
		if level_map_layers.is_empty():
			level_map_layers.append({"name": "Layer 1"})
		var level_art_layers = level.get("art_layers", [])
		if level_art_layers.is_empty():
			level_art_layers.append({"name": "Layer 1"})
		level.erase("layers")
	else:
		var level_map_layers = level.get("map_layers", [])
		if level_map_layers.is_empty():
			level_map_layers.append({"name": "Layer 1"})
		
		for encoded_map_layer in level_map_layers:
			# Emit add layer event
			emit_signal("level_event", {
				"type": EditorEvents.ADD_MAP_LAYER,
				"name": encoded_map_layer.name,
				"tile_map_rotation": encoded_map_layer.get("tile_map_rotation", 0),
				"z_axis": encoded_map_layer.get("z_axis", 10),
				"anchor": encoded_map_layer.get("anchor", {"x": 0, "y": 0})
			})
		
			if encoded_map_layer.get("chunks"):
				decode_chunks(encoded_map_layer.name, encoded_map_layer.chunks)
		
		
		var level_art_layers = level.get("art_layers", [])
		if level_art_layers.is_empty():
			level_art_layers.append({"name": "Layer 1"})
		
		for encoded_art_layer in level_art_layers:
			# Emit add layer event
			emit_signal("level_event", {
				"type": EditorEvents.ADD_ART_LAYER,
				"name": encoded_art_layer.name,
				"art_scale": encoded_art_layer.get("scale", 1.0),
				"art_rotation": encoded_art_layer.get("art_rotation", 0),
				"depth": encoded_art_layer.get("depth", 10),
				"z_axis": encoded_art_layer.get("z_axis", 10),
				"alpha": encoded_art_layer.get("alpha", 100),
				"anchor": encoded_art_layer.get("anchor", {"x": 0, "y": 0})
			})
		
			if encoded_art_layer.get("lines"):
				GeneralDecoder.decode_lines(encoded_art_layer.name, encoded_art_layer.lines)
			if encoded_art_layer.get("stamps"):
				GeneralDecoder.decode_stamps(encoded_art_layer.name, encoded_art_layer.stamps)
			if encoded_art_layer.get("texts"):
				GeneralDecoder.decode_texts(encoded_art_layer.name, encoded_art_layer.texts)
		

func decode_chunks(encoded_layer_name: String, chunks: Array) -> void:
	for chunk in chunks:
		for i:int in chunk.data.size():
			var tile_id:int = chunk.data[i]
			if tile_id == 0:
				continue
			var coords = Vector2i(chunk.x + (i % int(chunk.width)), chunk.y + (i / int(chunk.width)))
			var tile_options:Array = []
			if chunk.has("options") and chunk.options[i] != null:
				tile_options = chunk.options[i]
			
			# Emit set tile event
			emit_signal("level_event", {
				"type": EditorEvents.SET_TILE,
				"layer_name": encoded_layer_name,
				"coords": {"x": coords.x, "y": coords.y},
				"block_id": tile_id,
				"block_options": tile_options
			})
