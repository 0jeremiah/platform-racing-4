extends Node2D
class_name BlockDecoder

signal level_event


func decode(block: Dictionary, block_layers: BlockLayers) -> void:
	var properties = block.get("properties", {})
	var block_art_layers = block.get("art_layers", [])
	if block_art_layers.is_empty():
		block_art_layers.append({"name": "Layer 1"})
		
	for encoded_art_layer in block_art_layers:
		# Emit add layer event
		emit_signal("level_event", {
			"type": EditorEvents.ADD_ART_LAYER,
			"name": encoded_art_layer.name,
			"art_scale": encoded_art_layer.get("scale", 1.0),
			"art_rotation": encoded_art_layer.get("art_rotation", 0),
			"depth": encoded_art_layer.get("depth", 10),
			"z_axis": encoded_art_layer.get("z_axis", 10),
			"alpha": encoded_art_layer.get("alpha", 100)
		})
		
		if encoded_art_layer.get("lines"):
			decode_lines(encoded_art_layer.name, encoded_art_layer.lines)
		if encoded_art_layer.get("stamps"):
			decode_stamps(encoded_art_layer.name, encoded_art_layer.stamps)
		if encoded_art_layer.get("texts"):
			decode_texts(encoded_art_layer.name, encoded_art_layer.texts)
		

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
