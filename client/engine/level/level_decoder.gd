extends Node2D
class_name LevelDecoder

signal control_event
signal editor_event

var default_map_layer = {
	"name": "Layer 1",
	"tile_map_rotation": 0.0,
	"z_axis": 10,
	"anchor": {"x": 0, "y": 0}
	}
var default_art_layer = {
	"name": "Layer 1",
	"art_rotation": 0.0,
	"depth": 10,
	"z_axis": 10,
	"alpha": 100,
	"anchor": {"x": 0, "y": 0}
	}

func decode(level: Dictionary) -> void:
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
		var any_map_layers = false
		var any_art_layers = false
		if !layers.is_empty():
			for encoded_layer in layers:
				var chunks = encoded_layer.get("chunks", [])
				if !chunks.is_empty():
					any_map_layers = true
					# Emit add block layer event
					emit_signal("editor_event", {
						"type": EditorEvents.ADD_MAP_LAYER,
						"name": encoded_layer.name,
						"tile_map_rotation": encoded_layer.get("rotation", 0),
						"z_axis": encoded_layer.get("depth", 10),
						"anchor": {"x": 0, "y": 0},
						"z_index": encoded_layer.get("depth", 10)
					})
					if encoded_layer.get("chunks"):
						decode_chunks(encoded_layer.name, encoded_layer.chunks)
			for encoded_layer in layers:
				var lines = encoded_layer.get("lines", [])
				var texts = encoded_layer.get("texts", [])
				if !lines.is_empty() or !texts.is_empty():
					any_art_layers = true
					# Emit add art layer event
					emit_signal("editor_event", {
						"type": EditorEvents.ADD_ART_LAYER,
						"name": encoded_layer.name,
						"art_rotation": encoded_layer.get("rotation", 0),
						"depth": encoded_layer.get("depth", 10),
						"z_axis": encoded_layer.get("depth", 10),
						"alpha": 100,
						"anchor": {"x": 0, "y": 0},
						"z_index": encoded_layer.get("depth", 10)
					})
					if encoded_layer.get("lines"):
						GeneralDecoder.decode_lines(encoded_layer.name, encoded_layer.lines)
					if encoded_layer.get("usertextboxobjects"):
						GeneralDecoder.decode_texts(encoded_layer.name, encoded_layer.usertextboxobjects)
		if !any_map_layers:
			emit_signal("editor_event", {
				"type": EditorEvents.ADD_MAP_LAYER,
				"name": "Layer 1",
				"tile_map_rotation": 0.0,
				"z_axis": 10,
				"anchor": {"x": 0, "y": 0},
				"z_index": 10
			})
		if !any_art_layers:
			emit_signal("editor_event", {
				"type": EditorEvents.ADD_ART_LAYER,
				"name": "Layer 1",
				"art_rotation": 0.0,
				"depth": 10,
				"z_axis": 10,
				"alpha": 100,
				"anchor": {"x": 0, "y": 0},
				"z_index": 10
			})
	else:
		var level_map_layers = level.get("map_layers", [])
		if level_map_layers.is_empty():
			level_map_layers.append(default_map_layer)

		for encoded_map_layer in level_map_layers:
			# Emit add layer event
			emit_signal("editor_event", {
				"type": EditorEvents.ADD_MAP_LAYER,
				"name": encoded_map_layer.name,
				"tile_map_rotation": encoded_map_layer.get("tile_map_rotation", 0),
				"z_axis": encoded_map_layer.get("z_axis", 10),
				"anchor": encoded_map_layer.get("anchor", {"x": 0, "y": 0}),
				"z_index": encoded_map_layer.get("z_index", 10),
			})

			if encoded_map_layer.get("chunks"):
				decode_chunks(encoded_map_layer.name, encoded_map_layer.chunks)


		var level_art_layers = level.get("art_layers", [])
		if level_art_layers.is_empty():
			level_art_layers.append(default_art_layer)

		for encoded_art_layer in level_art_layers:
			# Emit add layer event
			emit_signal("editor_event", {
				"type": EditorEvents.ADD_ART_LAYER,
				"name": encoded_art_layer.name,
				"art_scale": encoded_art_layer.get("scale", 1.0),
				"art_rotation": encoded_art_layer.get("art_rotation", 0),
				"depth": encoded_art_layer.get("depth", 10),
				"z_axis": encoded_art_layer.get("z_axis", 10),
				"alpha": encoded_art_layer.get("alpha", 100),
				"anchor": encoded_art_layer.get("anchor", {"x": 0, "y": 0}),
				"z_index": encoded_art_layer.get("z_index", 10),
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
			# failsafe for chunks with data that isn't in the dictionary format
			if chunk.data[i] is not Dictionary:
				chunk.data[i] = {"id": str(int(chunk.data[i])), "settings": null}
			var tile_id:String = chunk.data[i].id
			if tile_id not in BlockManager._block_lookup or tile_id not in BlockManager._blocks:
				continue
			var coords = Vector2i(chunk.x + (i % int(chunk.width)), chunk.y + (i / int(chunk.width)))
			var tile_settings = {}
			if chunk.data[i].has("settings") and chunk.data[i].settings != null:
				tile_settings = chunk.data[i].settings
			
			# Emit set tile event
			emit_signal("editor_event", {
				"type": EditorEvents.SET_TILE,
				"layer_name": encoded_layer_name,
				"coords": {"x": coords.x, "y": coords.y},
				"block_id": tile_id,
				"block_settings": tile_settings
			})


func new_decode(level: Dictionary) -> void:
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
		var any_map_layers = false
		var any_art_layers = false
		if !layers.is_empty():
			for encoded_layer in layers:
				var chunks = encoded_layer.get("chunks", [])
				if !chunks.is_empty():
					any_map_layers = true
					# Emit add block layer event
					emit_signal("editor_event", {
						"type": EditorEvents.ADD_MAP_LAYER,
						"name": encoded_layer.name,
						"tile_map_rotation": encoded_layer.get("rotation", 0),
						"z_axis": encoded_layer.get("depth", 10),
						"anchor": {"x": 0, "y": 0},
						"z_index": encoded_layer.get("depth", 10)
					})
					if encoded_layer.get("chunks"):
						new_decode_chunks(encoded_layer.name, encoded_layer.chunks)
			for encoded_layer in layers:
				var lines = encoded_layer.get("lines", [])
				var texts = encoded_layer.get("texts", [])
				if !lines.is_empty() or !texts.is_empty():
					any_art_layers = true
					# Emit add art layer event
					emit_signal("editor_event", {
						"type": EditorEvents.ADD_ART_LAYER,
						"name": encoded_layer.name,
						"art_rotation": encoded_layer.get("rotation", 0),
						"depth": encoded_layer.get("depth", 10),
						"z_axis": encoded_layer.get("depth", 10),
						"alpha": 100,
						"anchor": {"x": 0, "y": 0},
						"z_index": encoded_layer.get("depth", 10)
					})
					if encoded_layer.get("lines"):
						GeneralDecoder.new_decode_lines(encoded_layer.name, encoded_layer.lines)
					if encoded_layer.get("usertextboxobjects"):
						GeneralDecoder.new_decode_texts(encoded_layer.name, encoded_layer.usertextboxobjects)
		if !any_map_layers:
			emit_signal("editor_event", {
				"type": EditorEvents.ADD_MAP_LAYER,
				"name": "Layer 1",
				"tile_map_rotation": 0.0,
				"z_axis": 10,
				"anchor": {"x": 0, "y": 0},
				"z_index": 10
			})
		if !any_art_layers:
			emit_signal("editor_event", {
				"type": EditorEvents.ADD_ART_LAYER,
				"name": "Layer 1",
				"art_rotation": 0.0,
				"depth": 10,
				"z_axis": 10,
				"alpha": 100,
				"anchor": {"x": 0, "y": 0},
				"z_index": 10
			})
	else:
		var level_map_layers = level.get("map_layers", [])
		if level_map_layers.is_empty():
			level_map_layers.append(default_map_layer)

		for encoded_map_layer in level_map_layers:
			# Emit add layer event
			emit_signal("editor_event", {
				"type": EditorEvents.ADD_MAP_LAYER,
				"name": encoded_map_layer.name,
				"tile_map_rotation": encoded_map_layer.get("tile_map_rotation", 0),
				"z_axis": encoded_map_layer.get("z_axis", 10),
				"anchor": encoded_map_layer.get("anchor", {"x": 0, "y": 0}),
				"z_index": encoded_map_layer.get("z_index", 10),
			})

			if encoded_map_layer.get("chunks"):
				new_decode_chunks(encoded_map_layer.name, encoded_map_layer.chunks)


		var level_art_layers = level.get("art_layers", [])
		if level_art_layers.is_empty():
			level_art_layers.append(default_art_layer)

		for encoded_art_layer in level_art_layers:
			# Emit add layer event
			emit_signal("editor_event", {
				"type": EditorEvents.ADD_ART_LAYER,
				"name": encoded_art_layer.name,
				"art_scale": encoded_art_layer.get("scale", 1.0),
				"art_rotation": encoded_art_layer.get("art_rotation", 0),
				"depth": encoded_art_layer.get("depth", 10),
				"z_axis": encoded_art_layer.get("z_axis", 10),
				"alpha": encoded_art_layer.get("alpha", 100),
				"anchor": encoded_art_layer.get("anchor", {"x": 0, "y": 0}),
				"z_index": encoded_art_layer.get("z_index", 10),
			})

			if encoded_art_layer.get("lines"):
				GeneralDecoder.new_decode_lines(encoded_art_layer.name, encoded_art_layer.lines)
			if encoded_art_layer.get("stamps"):
				GeneralDecoder.new_decode_stamps(encoded_art_layer.name, encoded_art_layer.stamps)
			if encoded_art_layer.get("texts"):
				GeneralDecoder.new_decode_texts(encoded_art_layer.name, encoded_art_layer.texts)


func new_decode_chunks(encoded_layer_name: String, chunks_container: String) -> void:
	var chunks_array = chunks_container.split("`")
	for chunk_string in chunks_array:
		var chunks = str_to_var(chunk_string) # if done correctly this should be an array
		if chunks is Array:
			for chunk in chunks:
				for i:int in chunk.data.size():
					# failsafe for chunks with data that isn't in the dictionary format
					if chunk.data[i] is not Dictionary:
						chunk.data[i] = {"id": str(int(chunk.data[i])), "settings": null}
					if "id" not in chunk.data[i]:
						continue
					var tile_id:String = chunk.data[i].id
					if tile_id not in BlockManager._block_lookup or tile_id not in BlockManager._blocks:
						continue
					var coords = Vector2i(chunk.x + (i % int(chunk.width)), chunk.y + (i / int(chunk.width)))
					var tile_settings = {}
					if chunk.data[i].has("settings") and chunk.data[i].settings != null:
						tile_settings = chunk.data[i].settings
					
					# Emit set tile event
					emit_signal("editor_event", {
						"type": EditorEvents.SET_TILE,
						"layer_name": encoded_layer_name,
						"coords": {"x": coords.x, "y": coords.y},
						"block_id": tile_id,
						"block_settings": tile_settings
					})
