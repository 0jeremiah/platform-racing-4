extends Node

signal editor_event


func decode_lines(layer_name: String, objects: Array) -> void:
	for object in objects:
		# checks if the line is actually a line or a stamp. (compatibility for pr3)
		if object.has("type") and object.type == "stamp":
			emit_signal("editor_event", {
				"type": EditorEvents.ADD_LINE,
				"layer_name": layer_name,
				"line_type": "stamp",
				"id": object.id,
				"position": object.position,
				"scale": object.scale,
				"rotation": object.rotation,
			})
		else:
			var points_array = []
			for point in object.points:
				points_array.append({"x": point.x, "y": point.y})
			
			# Emit add line event
			var line_color
			if typeof(object.color) == TYPE_STRING:
				line_color = object.color
			else:
				line_color = Color(object.color[0], object.color[1], object.color[2], object.color[3]).to_html(true)

			# changes line blend mode
			var line_mode = "draw"
			var line_material = CanvasItemMaterial.new()
			if object.has("mode") and object.mode == "erase":
				line_material.blend_mode = CanvasItemMaterial.BLEND_MODE_SUB
				line_mode = "erase"
			else:
				line_material.blend_mode = CanvasItemMaterial.BLEND_MODE_PREMULT_ALPHA
		
			emit_signal("editor_event", {
				"type": EditorEvents.ADD_LINE,
				"layer_name": layer_name,
				"line_type": "line",
				"position": {"x": object.x, "y": object.y},
				"points": points_array,
				"color": line_color,
				"thickness": object.thickness,
				"mode": line_mode
			})


func decode_stamps(layer_name: String, objects: Array) -> void:
	for object in objects:
			
		emit_signal("editor_event", {
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
		emit_signal("editor_event", {
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


func new_decode_lines(layer_name: String, objects_container: String) -> void:
	var objects_array = objects_container.split("`")
	for object_string in objects_array:
		var objects = str_to_var(object_string) # if done correctly this should be an array
		if objects is Array:
			for object in objects:
				# checks if the line is actually a line or a stamp. (compatibility for pr3)
				if object.has("type") and object.type == "stamp":
					emit_signal("editor_event", {
						"type": EditorEvents.ADD_LINE,
						"layer_name": layer_name,
						"line_type": "stamp",
						"id": object.id,
						"position": object.position,
						"scale": object.scale,
						"rotation": object.rotation,
					})
				else:
					var points_array = []
					for point in object.points:
						points_array.append({"x": point.x, "y": point.y})
					
					# Emit add line event
					var line_color
					if typeof(object.color) == TYPE_STRING:
						line_color = object.color
					else:
						line_color = Color(object.color[0], object.color[1], object.color[2], object.color[3]).to_html(true)

					# changes line blend mode
					var line_material = CanvasItemMaterial.new()
					var line_mode = "draw"
					if object.has("mode") and object.mode == "erase":
						line_material.blend_mode = CanvasItemMaterial.BLEND_MODE_SUB
						line_mode = "erase"
					else:
						line_material.blend_mode = CanvasItemMaterial.BLEND_MODE_PREMULT_ALPHA
				
					emit_signal("editor_event", {
						"type": EditorEvents.ADD_LINE,
						"layer_name": layer_name,
						"line_type": "line",
						"position": {"x": object.x, "y": object.y},
						"points": points_array,
						"color": line_color,
						"thickness": object.thickness,
						"mode": line_mode
					})


func new_decode_stamps(layer_name: String, objects_container: String) -> void:
	var objects_array = objects_container.split("`")
	for object_string in objects_array:
		var objects = str_to_var(object_string) # if done correctly this should be an array
		if objects is Array:
			for object in objects:
				emit_signal("editor_event", {
					"type": EditorEvents.ADD_STAMP,
					"layer_name": layer_name,
					"id": object.id,
					"position": object.position,
					"scale": object.scale,
					"rotation": object.rotation,
				})


func new_decode_texts(layer_name: String, objects_container: String) -> void:
	var objects_array = objects_container.split("`")
	for object_string in objects_array:
		var objects = str_to_var(object_string) # if done correctly this should be an array
		if objects is Array:
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
				emit_signal("editor_event", {
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
