extends Node

var mega_lines_size = 1000
var mega_stamps_size = 1000
var mega_texts_size = 1000

func encode_lines(node: Node2D) -> Array:
	var lines = []
	for child in node.get_children():
		if child is Line2D:
			var pointObjects = []
			for point in child.points:
				pointObjects.push_back({"x": point.x, "y": point.y})
			var line_mode = "draw"
			if child.material.blend_mode == CanvasItemMaterial.BLEND_MODE_SUB:
				line_mode = "erase"
			var lineData = {
				"line_type": "line",
				"x": child.position.x,
				"y": child.position.y,
				"points": pointObjects.slice(1, len(pointObjects)), # the first point should always be 0,0, we can leave it out
				"color": child.default_color.to_html(false),
				"thickness": child.width,
				"mode": line_mode
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


func new_encode_lines(node: Node2D) -> String:
	var save_string = ""
	var lines_array: Array = []
	for child in node.get_children():
		if child is Line2D or child is Sprite2D:
			lines_array.append(child.get_index())
	var array_counter = 0
	var compat_lines = []
	if lines_array.size() > mega_lines_size:
		while mega_lines_size * array_counter < lines_array.size():
			compat_lines.append(lines_array.slice(mega_lines_size * array_counter, mega_lines_size * (array_counter + 1)))
			array_counter += 1
	else:
		compat_lines = [lines_array]
	for compat_line in compat_lines:
		var lines = []
		for line in compat_line:
			var line_node = node.get_child(line)
			if line_node is Line2D:
				var pointObjects = []
				for point in line_node.points:
					pointObjects.push_back({"x": point.x, "y": point.y})
				var line_mode = "draw"
				if line_node.material.blend_mode == CanvasItemMaterial.BLEND_MODE_SUB:
					line_mode = "erase"
				var lineData = {
					"line_type": "line",
					"x": line_node.position.x,
					"y": line_node.position.y,
					"points": pointObjects.slice(1, len(pointObjects)), # the first point should always be 0,0, we can leave it out
					"color": line_node.default_color.to_html(false),
					"thickness": line_node.width,
					"mode": line_mode
				}
				lines.push_back(lineData)
			elif line_node is Sprite2D:
				var stampData = {
					"line_type": "stamp",
					"id": line_node.stamp_id,
					"position": {"x": line_node.stamp_position.x, "y": line_node.stamp_position.y},
					"scale": {"x": line_node.stamp_scale.x, "y": line_node.stamp_scale.y},
					"rotation": line_node.stamp_rotation
				}
				lines.push_back(stampData)
		if save_string != "":
			save_string = save_string + "`" + JSON.stringify(lines)
		else:
			save_string = save_string + JSON.stringify(lines)
	return save_string


func new_encode_stamps(node: Node2D) -> String:
	var save_string = ""
	var stamps_array: Array = []
	for child: Node2D in node.get_children():
		stamps_array.append(child.get_index())
	var array_counter = 0
	var compat_stamps = []
	if stamps_array.size() > mega_stamps_size:
		while mega_stamps_size * array_counter < stamps_array.size():
			compat_stamps.append(stamps_array.slice(mega_stamps_size * array_counter, mega_stamps_size * (array_counter + 1)))
			array_counter += 1
	else:
		compat_stamps = [stamps_array]
	for compat_stamp in compat_stamps:
		var stamps = []
		for stamp in compat_stamp:
			var stamp_node = node.get_child(stamp)
			if stamp_node:
				var stampData = {
					"id": stamp_node.stamp_id,
					"position": {"x": stamp_node.stamp_position.x, "y": stamp_node.stamp_position.y},
					"scale": {"x": stamp_node.stamp_scale.x, "y": stamp_node.stamp_scale.y},
					"rotation": stamp_node.stamp_rotation
				}
				stamps.push_back(stampData)
		if save_string != "":
			save_string = save_string + "`" + JSON.stringify(stamps)
		else:
			save_string = save_string + JSON.stringify(stamps)
	return save_string


func new_encode_texts(node: Node2D) -> String:
	var save_string = ""
	var texts_array: Array = []
	for child: Node2D in node.get_children():
		texts_array.append(child.get_index())
	var array_counter = 0
	var compat_texts = []
	if texts_array.size() > mega_texts_size:
		while mega_texts_size * array_counter < texts_array.size():
			compat_texts.append(texts_array.slice(mega_texts_size * array_counter, mega_texts_size * (array_counter + 1)))
			array_counter += 1
	else:
		compat_texts = [texts_array]
	for compat_text in compat_texts:
		var texts = []
		for text in compat_text:
			var text_node = node.get_child(text)
			if text_node:
				var textData = {
					"text": text_node.text_string,
					"font": text_node.text_font,
					"font_size": text_node.text_font_size,
					"scale": {"x": text_node.text_scale.x, "y": text_node.text_scale.y},
					"position": {"x": text_node.text_position.x, "y": text_node.text_position.y},
					"rotation": text_node.text_rotation,
					"color": text_node.text_color
				}
				texts.push_back(textData)
		if save_string != "":
			save_string = save_string + "`" + JSON.stringify(texts)
		else:
			save_string = save_string + JSON.stringify(texts)
	return save_string
