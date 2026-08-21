extends Node2D

signal editor_event

@onready var haircross = $Haircross
@onready var brush_circle = $BrushCircle

var active: bool = false
var current_layers = null
var cursor_parent = null
var current_line: Line2D
var current_point: Vector2i
var optimization_epsilon: float = 1.0 # bigger = more line optimization
var mode: String = "draw"
var draw_size: float = 5.0
var erase_size: float = 5.0
var size_multiplier: float = 2
var draw_color: Color = Color(0.0, 0.0, 0.0) # Default to black
var draw_alpha: float = 100.0
var erase_alpha: float = 100.0


func _ready() -> void:
	pass


func deactivate():
	active = false


func activate():
	active = true


func _process(_delta):
	if active:
		visible = true
		haircross.visible = false
		brush_circle.visible = false
		var touching_gui: bool = get_parent().touching_gui
		if touching_gui:
			var camera: Camera2D = get_viewport().get_camera_2d()
			var camera_zoom = camera.zoom.x
			if "camera_zoom" in camera:
				camera_zoom = camera.camera_zoom
			haircross.visible = true
			brush_circle.visible = true
			if mode == "erase":
				brush_circle.set_brush_circle(erase_size * (camera_zoom * 2), size_multiplier)
			else:
				brush_circle.set_brush_circle(draw_size * (camera_zoom * 2), size_multiplier)
	else:
		visible = false


func init(_current_layers, _cursor_parent) -> void:
	print("DrawCursor::init")
	if _current_layers is LevelLayers or _current_layers is BlockLayers:
		current_layers = _current_layers
	cursor_parent = _cursor_parent
	cursor_parent.editor_menu.connect("control_event", _on_control_event)


func _on_control_event(event: Dictionary) -> void:
	if active:
		print("DrawCursor::_on_control_event", event)
		if event.type == EditorEvents.SELECT_BRUSH_MODE:
			mode = event.mode


func on_mouse_down():
	if active and cursor_parent.editor_menu.can_edit and cursor_parent.editor_menu.can_edit:
		if !current_line:
			print("DrawCursor::on_mouse_down")
			var layer: Parallax2D = current_layers.art_layers.get_node(current_layers.get_target_art_layer())
			var lines: Node2D = layer.lines
			var camera: Camera2D = get_viewport().get_camera_2d()
			var mouse_position = lines.get_local_mouse_position()
			current_line = Line2D.new()
			lines.add_child(current_line)
			current_line.material = CanvasItemMaterial.new()
			current_line.end_cap_mode = Line2D.LINE_CAP_ROUND
			current_line.begin_cap_mode = Line2D.LINE_CAP_ROUND
			current_line.position = mouse_position.round()
			if mode == "erase":
				current_line.material.blend_mode = CanvasItemMaterial.BLEND_MODE_SUB
				current_line.default_color = Color(0.0, 0.0, 0.0, erase_alpha)
				current_line.width = erase_size * size_multiplier
			else:
				current_line.material.blend_mode = CanvasItemMaterial.BLEND_MODE_MIX
				current_line.default_color = Color(draw_color.r, draw_color.g, draw_color.b, draw_alpha)
				current_line.width = draw_size * size_multiplier
			current_line.add_point(Vector2i(0, 0))
			current_point = Vector2i(0, 0)


func on_drag():
	if active and cursor_parent.editor_menu.can_edit:
		if current_line:
			var layer: Parallax2D = current_layers.art_layers.get_node(current_layers.get_target_art_layer())
			var lines: Node2D = layer.lines
			var camera: Camera2D = get_viewport().get_camera_2d()
			var mouse_position = lines.get_local_mouse_position()
			var point = Vector2i((mouse_position - current_line.position).round())
			if point != current_point:
				current_line.add_point(point)
				current_point = point


func on_mouse_up():
	if active and cursor_parent.editor_menu.can_edit:
		if current_line:
			# Just clicks with no drag should produce a dot
			if len(current_line.points) == 1:
				current_line.add_point(Vector2i(1, 1))
			# Simplify the line
			var simplified_points = douglas_peucker(current_line.points, optimization_epsilon)
			var point_dicts = []
			for point in simplified_points:
				point_dicts.append({"x": point.x, "y": point.y})
			emit_signal("editor_event", {
				"type": EditorEvents.ADD_LINE,
				"layer_name": current_layers.get_target_art_layer(),
				"line_type": "line",
				"position": {
					"x": current_line.position.x,
					"y": current_line.position.y
				},
				"points": point_dicts,
				"width": current_line.width,
				"color": current_line.default_color.to_html(true), # Include alpha in hex format (e.g. FFFFFFFF)
				"mode": mode
			})
			# Remove the temporary line
			current_line.queue_free()


# Function to calculate the perpendicular distance from a point to a line formed by two points
func perpendicular_distance(point, line_start, line_end):
	if line_start == line_end:
		return (line_start - point).length()
	else:
		var n = abs((line_end.x - line_start.x) * (line_start.y - point.y) - (line_start.x - point.x) * (line_end.y - line_start.y))
		var d = (line_end - line_start).length()
		return n / d


# Recursive function implementing the Douglas-Peucker algorithm
func douglas_peucker(points, epsilon):
	# Find the point with the maximum distance from line between the start and end
	var max_distance = 0
	var index = 0
	for i in range(1, points.size() - 1):
		var dist = perpendicular_distance(points[i], points[0], points[-1])
		if dist > max_distance:
			index = i
			max_distance = dist
	# If max distance is greater than epsilon, recursively simplify
	if max_distance > epsilon:
		# Recursive call
		var rec_results1 = douglas_peucker(points.slice(0, index + 1), epsilon)
		var rec_results2 = douglas_peucker(points.slice(index), epsilon)
		# Build the result list
		var result = rec_results1 + rec_results2.slice(1)
		return result
	else:
		# None are far enough to keep any point except the endpoints
		return [points[0], points[-1]]


func set_draw_size(new_size: int) -> void:
	draw_size = new_size


func set_draw_color(new_color: Color) -> void:
	draw_color = new_color


func set_draw_alpha(new_alpha: float) -> void:
	draw_alpha = new_alpha


func set_erase_size(new_size: int) -> void:
	erase_size = new_size


func set_erase_alpha(new_alpha: float) -> void:
	erase_alpha = new_alpha
