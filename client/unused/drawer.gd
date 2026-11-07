extends Node2D
var draw_lines: Dictionary = {}
var current_location: Vector2 = Vector2(0, 0)
var sample_line: Line2D = Line2D.new()


func _draw_line(location: Vector2, color: Color, width: float):
	if draw_lines.is_empty():
		sample_line.default_color = color
		sample_line.width = width
	draw_lines.get_or_add("draw_line" + str(draw_lines.size() + 1), {"location": location, "color": color, "width": width})
	if current_location != location:
		sample_line.add_point(location)
		current_location = location


func _clear():
	draw_lines.clear()
	sample_line.clear_points()


func _get_line(mode: String):
	if !draw_lines.is_empty() and (mode == "draw" or mode == "erase"):
		var new_line = Line2D.new()
		new_line.closed = false
		new_line.antialiased = false
		new_line.begin_cap_mode = 2
		new_line.end_cap_mode = 2
		new_line.material = CanvasItemMaterial.new()
		if mode == "erase":
			new_line.material.blend_mode = CanvasItemMaterial.BLEND_MODE_SUB
		else:
			new_line.material.blend_mode = CanvasItemMaterial.BLEND_MODE_MIX
		for line in draw_lines:
			new_line.default_color = draw_lines[line].color
			new_line.width = draw_lines[line].width
			new_line.add_point(draw_lines[line].location)
		if draw_lines.size() == 1:
			new_line.add_point(draw_lines[0].location.x + 1, draw_lines[0].location.y + 1)
		return new_line
	else:
		return null
