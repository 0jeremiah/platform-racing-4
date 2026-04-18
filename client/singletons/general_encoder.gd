extends Node


func encode_lines(node: Node2D) -> Array:
	var lines = []
	for child in node.get_children():
		if child is Line2D:
			var pointObjects = []
			for point in child.points:
				pointObjects.push_back({"x": point.x, "y": point.y})
			var lineData = {
				"line_type": "line",
				"x": child.position.x,
				"y": child.position.y,
				"points": pointObjects.slice(1, len(pointObjects)), # the first point should always be 0,0, we can leave it out
				"color": child.default_color,
				"thickness": child.width,
				"material": child.material
			}
			lines.push_back(lineData)
		elif child is Sprite2D:
			var stampData = {
				"line_type": "stamp",
				"id": child.stamp_id,
				"position": {"x": child.stamp_position.x, "y": child.stamp_position.y},
				"scale": {"x": child.stamp_scale.x, "y": child.stamp_scale.y},
				"rotation": child.stamp_rotation
			}
			lines.push_back(stampData)
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
