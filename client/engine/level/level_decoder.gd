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
						decode_lines(encoded_layer.name, encoded_layer.lines)
					if encoded_layer.get("usertextboxobjects"):
						decode_texts(encoded_layer.name, encoded_layer.usertextboxobjects)
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
				decode_lines(encoded_art_layer.name, encoded_art_layer.lines)
			if encoded_art_layer.get("stamps"):
				decode_stamps(encoded_art_layer.name, encoded_art_layer.stamps)
			if encoded_art_layer.get("texts"):
				decode_texts(encoded_art_layer.name, encoded_art_layer.texts)
		

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


func decode_lines(layer_name: String, objects: Array) -> void:
	for object in objects:
			
		var points_array = []
		for point in object.points:
			points_array.append({"x": point.x, "y": point.y})
			
		# Emit add line event
		var line_color
		if typeof(object.color) == TYPE_STRING:
			line_color = object.color
		else:
			line_color = Color(object.color[0], object.color[1], object.color[2], object.color[3]).to_html(true)

		# add material if it exists
		var line_material = CanvasItemMaterial.new()
		if object.has("material"):
			line_material = object.material
		else:
			line_material.blend_mode = CanvasItemMaterial.BLEND_MODE_PREMULT_ALPHA
		
		emit_signal("level_event", {
			"type": EditorEvents.ADD_LINE,
			"layer_name": layer_name,
			"position": {"x": object.x, "y": object.y},
			"points": points_array,
			"color": line_color,
			"thickness": object.thickness,
			"material": line_material
		})


func decode_stamps(layer_name: String, objects: Array) -> void:
	for object in objects:
			
		emit_signal("level_event", {
			"type": EditorEvents.ADD_STAMP,
			"layer_name": layer_name,
			"id": object.id,
			"position": object.position,
			"scale": object.scale,
			"rotation": object.rotation,
		})


func decode_texts(layer_name: String, objects: Array) -> void:
	for object in objects:
		
		#Failsafes for old text.
		
		# usertextbox renamed to text (or textbox)
		if object.has("usertext"): 
			object.get_or_add("text", "Text!")
			object.text = object.usertext
			object.erase("usertext")
		
		# adds font if it doesn't exist
		# font is now just the id of the font rather than the path of the font
		if object.has("font") and object.font.begins_with("res://"):
			object.font = "poetsenone"
		elif !object.has("font"):
			object.get_or_add("font")
			object.font = "poetsenone"
		
		# adds font_size if it doesn't exist
		# font is now just the id of the font rather than the path of the font
		if object.has("font_size"):
			object.get_or_add("font_size", 14)
		
		# deletes text_width/text_height and width/height and replaces them with scale
		if object.has("text_width"):
			object.erase("text_width")
			object.get_or_add("scale", {"x": 1})
		elif object.has("width"):
			object.get_or_add("scale", {"x": 1})
			object.scale.x = object.width
			object.erase("width")

		if object.has("text_height"):
			object.erase("text_height")
			object.get_or_add("scale", {"y": 1})
		elif object.has("height"):
			object.get_or_add("scale", {"y": 1})
			object.scale.y = object.height
			object.erase("height")

		# deletes x/y and replaces them with position
		if object.has("x"):
			object.get_or_add("position", {"x": 0, "y": 0})
			object.position.x = object.x
			object.erase("x")
		if object.has("y"):
			object.get_or_add("position", {"x": 0, "y": 0})
			object.position.y = object.y
			object.erase("y")

		# text_rotation renamed to rotation
		if object.has("text_rotation"):
			object.get_or_add("rotation", 0)
			object.rotation = int(object.text_rotation)
			object.erase("text_rotation")
		elif !object.has("rotation"):
			object.get_or_add("rotation", 0)
		
		# adds color if it doesn't exist
		if !object.has("color"):
			object.get_or_add("color", "000000")
		
		# Emit add usertext event
		emit_signal("level_event", {
			"type": EditorEvents.ADD_TEXT,
			"layer_name": layer_name,
			"text": object.text,
			"font": object.font,
			"font_size": object.font_size,
			"scale": object.scale,
			"position": object.position,
			"rotation": object.rotation,
			"color": object.color
		})
