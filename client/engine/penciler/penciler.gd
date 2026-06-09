extends Node2D

const CLEANUP_INTERVAL = 60  # 600 seconds (1 minutes)
var last_cleanup_time = 0
var tile_update_timestamps = {}
var current_layers = null
var layer_panel: Node2D


func _ready() -> void:
	GeneralDecoder.connect("editor_event", _on_editor_event)
	GeneralEncoder.connect("editor_event", _on_editor_event)


func init(p_current_layers, event_source) -> void:
	if p_current_layers is LevelLayers or p_current_layers is BlockLayers:
		current_layers = p_current_layers
		event_source.connect("editor_event", _on_editor_event)


func _process(_delta: float) -> void:
	var current_time = Time.get_unix_time_from_system()
	if current_time - last_cleanup_time >= CLEANUP_INTERVAL:
		_cleanup_old_timestamps()
		last_cleanup_time = current_time


func _cleanup_old_timestamps() -> void:
	var current_time = Time.get_unix_time_from_system()
	for key in tile_update_timestamps.keys():
		if current_time - tile_update_timestamps[key] > CLEANUP_INTERVAL:
			tile_update_timestamps.erase(key)


func _on_editor_event(event: Dictionary) -> void:
	if event.type == EditorEvents.SET_TILE:
		var coords = Vector2i(event.coords.x, event.coords.y)
		var coords_key = str(coords.x) + "_" + str(coords.y)
		
		if event.has("timestamp"):
			var new_timestamp = event.timestamp
			
			if not tile_update_timestamps.has(coords_key) or tile_update_timestamps[coords_key] < new_timestamp:
				_set_tile(event, coords, coords_key, new_timestamp)
		else:
			_set_tile(event, coords, coords_key)

	if event.type == EditorEvents.ADD_LINE:
		var layer = current_layers.art_layers.get_node(event.layer_name)
		var lines: Node2D = current_layers.art_layers.get_node(event.layer_name).lines
		if event.has("line_type") and event.line_type == "stamp":
			var stamp_scene: PackedScene = preload("res://engine/stamp/stamp.tscn")
			var stamp = stamp_scene.instantiate()
			var stamp_dictionary: Dictionary = {
				"id": event.id,
				"position": event.position,
				"scale": event.scale,
				"rotation": event.rotation
			}
			lines.add_child(stamp)
			stamp.set_stamp_properties(stamp_dictionary)
		else:
			var line = Line2D.new()
			lines.add_child(line)
			line.end_cap_mode = Line2D.LINE_CAP_ROUND
			line.begin_cap_mode = Line2D.LINE_CAP_ROUND
			line.position = Vector2(event.position.x, event.position.y)

			var converted_points = []

			# if the first point is not 0,0, add 0,0 as the first point
			if len(event.points) == 0 || event.points[0].x != 0 || event.points[0].y != 0:
				converted_points.append(Vector2.ZERO)

			# convert point objects into Vector2
			for point_dict in event.points:
				converted_points.append(Vector2(point_dict.x, point_dict.y))

			# if there is only one point, add another one. Need at least two points to draw a line
			if len(converted_points) == 1:
				converted_points.append(converted_points[0] + Vector2(0.1, 0.1))

			#
			line.points = converted_points

			# Set line color, width, and material if provided in the event
			if event.has("color"):
				if event.color is Color:
					line.default_color = event.color
				else:
					line.default_color = Color(event.color)
			if event.has("width"):
				line.width = event.width
			if event.has("thickness"):
				line.width = event.thickness
			if event.has("material"):
				line.material = event.material
			else:
				line.material = CanvasItemMaterial.new()
				line.material.blend_mode = CanvasItemMaterial.BLEND_MODE_PREMULT_ALPHA

	if event.type == EditorEvents.ADD_MAP_LAYER:
		var layer = current_layers.add_map_layer(event.name)
		layer.set_map_layer_rotation(event.get("tile_map_rotation", 0))
		layer.set_z_axis(event.get("z_axis", 10))
		layer.set_anchor(Vector2(event.get("anchor", {"x": 0, "y": 0}).x, event.get("anchor", {"x": 0, "y": 0}).y))
		layer.layer_name = event.name
	
	if event.type == EditorEvents.ADD_ART_LAYER:
		var layer = current_layers.add_art_layer(event.name)
		layer.set_art_rotation(event.get("art_rotation", 0))
		layer.set_depth(event.get("depth", 10))
		layer.set_z_axis(event.get("z_axis", 10))
		layer.set_art_alpha(event.get("alpha", 100))
		layer.set_anchor(Vector2(event.get("anchor", {"x": 0, "y": 0}).x, event.get("anchor", {"x": 0, "y": 0}).y))
		current_layers.set_target_art_layer(event.name)
		layer.layer_name = event.name
		current_layers.emit_signal("layers_changed")
	
	if event.type == EditorEvents.ADD_STAMP:
		var layer = current_layers.art_layers.get_node(event.layer_name)
		var stamps = layer.stamps
		var stamp_scene: PackedScene = preload("res://engine/stamp/stamp.tscn")
		var stamp = stamp_scene.instantiate()
		var stamp_dictionary: Dictionary = {
			"id": event.id,
			"position": event.position,
			"scale": event.scale,
			"rotation": event.rotation
		}
		stamps.add_child(stamp)
		stamp.set_stamp_properties(stamp_dictionary)
	
	if event.type == EditorEvents.SET_STAMP_POSITION:
		var layer = current_layers.art_layers.get_node(event.layer_name)
		var stamp = layer.stamps.get_node(event.stamp_name)
		stamp.set_stamp_position(Vector2(event.position.x, event.position.y))
	
	if event.type == EditorEvents.SET_STAMP_SCALE:
		var layer = current_layers.art_layers.get_node(event.layer_name)
		var stamp = layer.stamps.get_node(event.stamp_name)
		stamp.set_stamp_scale(Vector2(event.scale.x, event.scale.y))
	
	if event.type == EditorEvents.SET_STAMP_ROTATION:
		var layer = current_layers.art_layers.get_node(event.layer_name)
		var stamp = layer.stamps.get_node(event.stamp_name)
		stamp.set_stamp_rotation(event.rotation)
	
	if event.type == EditorEvents.DELETE_STAMP:
		var layer = current_layers.art_layers.get_node(event.layer_name)
		layer.delete_stamp(event.stamp_name)
	
	if event.type == EditorEvents.RENAME_MAP_LAYER:
		var layer = current_layers.map_layers.get_node(event.layer_name)
		layer.name = event.new_layer_name
		current_layers.set_target_map_layer(layer.name)
		layer.set_layer_name(event.new_layer_name)
	
	if event.type == EditorEvents.RENAME_ART_LAYER:
		var layer = current_layers.art_layers.get_node(event.layer_name)
		layer.name = event.new_layer_name
		current_layers.set_target_art_layer(layer.name)
		layer.set_layer_name(event.new_layer_name)

	if event.type == EditorEvents.DELETE_MAP_LAYER:
		current_layers.remove_map_layer(event.name)
	
	if event.type == EditorEvents.DELETE_ART_LAYER:
		current_layers.remove_art_layer(event.name)

	if event.type == EditorEvents.ADD_TEXT:
		var layer = current_layers.art_layers.get_node(event.layer_name)
		var texts: Node2D = layer.texts
		var text_scene: PackedScene = preload("res://engine/textbox.tscn")
		var text = text_scene.instantiate()
		var text_info: Dictionary = {
			"text": event.text,
			"font": event.font,
			"font_size": event.font_size,
			"scale": event.scale,
			"position": event.position,
			"rotation": event.rotation,
			"color": event.color
		}
		texts.add_child(text)
		text.set_text_properties(text_info)
	
	if event.type == EditorEvents.DELETE_TEXT:
		var layer = current_layers.art_layers.get_node(event.layer_name)
		layer.delete_text(event.text_name)

	if event.type == EditorEvents.SET_MAP_LAYER_Z_AXIS:
		var layer = current_layers.map_layers.get_node(event.layer_name)
		layer.set_z_axis(event.z_axis)
	
	if event.type == EditorEvents.SET_ART_LAYER_Z_AXIS:
		var layer = current_layers.art_layers.get_node(event.layer_name)
		layer.set_z_axis(event.z_axis)
	
	if event.type == EditorEvents.SET_ART_LAYER_DEPTH:
		var layer = current_layers.art_layers.get_node(event.layer_name)
		layer.set_depth(event.depth)
	
	if event.type == EditorEvents.SET_MAP_LAYER_ROTATION:
		var layer = current_layers.map_layers.get_node(event.layer_name)
		layer.set_map_layer_rotation(event.rotation)
	
	if event.type == EditorEvents.SET_ART_LAYER_ROTATION:
		var layer = current_layers.art_layers.get_node(event.layer_name)
		layer.set_art_rotation(event.rotation)
	
	if event.type == EditorEvents.SET_ART_LAYER_ALPHA:
		var layer = current_layers.art_layers.get_node(event.layer_name)
		layer.set_art_alpha(event.alpha)
	
	if event.type == EditorEvents.SET_MAP_LAYER_ANCHOR:
		var layer = current_layers.map_layers.get_node(event.layer_name)
		layer.set_anchor(Vector2(event.anchor.x, event.anchor.y))
	
	if event.type == EditorEvents.SET_ART_LAYER_ANCHOR:
		var layer = current_layers.art_layers.get_node(event.layer_name)
		layer.set_anchor(Vector2(event.anchor.x, event.anchor.y))
	
	if event.type == EditorEvents.SET_ART_LAYER_BLOCK_EFFECTS:
		var layer = current_layers.art_layers.get_node(event.layer_name)
		layer.set_block_effect_settings(event.block_effect_settings)


func _set_tile(event: Dictionary, coords: Vector2i, coords_key: String, new_timestamp: int = -1) -> void:
	var layer = current_layers.map_layers.get_node(event.layer_name)
	var tile_map_layer: ConfigurableTileMapLayer = current_layers.map_layers.get_node(event.layer_name).tile_map_layer
	if event.block_id:
		tile_map_layer.set_cell_by_id(coords, str(event.block_id))
	else:
		tile_map_layer.erase_cell(coords)
	
	if new_timestamp != -1:
		tile_update_timestamps[coords_key] = new_timestamp
