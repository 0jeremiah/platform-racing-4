extends Node2D
class_name BlockEncoder


func encode(block_layers: Node2D, block_manager: BlockManager) -> Dictionary:
	var block = {
		"title": BlockEditor.current_block_name,
		"description": BlockEditor.current_block_description,
		"art_layers": [],
		"properties": {}
	}
	for group_layer in block_layers.art_layers.get_children():
		if group_layer is ArtLayer:
			var art_layer = {
				"name": group_layer.name,
				"lines": encode_lines(group_layer.lines),
				"stamps": encode_stamps(group_layer.stamps),
				"texts": encode_texts(group_layer.texts),
				"rotation": group_layer.art_rotation,
				"depth": group_layer.depth,
				"alpha": group_layer.alpha
			}
			block.art_layers.push_back(art_layer)
	return block


func encode_lines(node: Node2D) -> Array:
	var lines = []
	
	for line: Line2D in node.get_children():
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
	for text: Control in node.get_children():
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
