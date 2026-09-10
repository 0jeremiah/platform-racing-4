extends Control

signal set_new_color

@onready var hsv_rectangle = $ColorOptions/HSVRectangle
@onready var rgb_sliders = $ColorOptions/RGBSliders
@onready var hex_code = $ColorOptions/HexCode
@onready var ok_button = $ColorOptions/OKButton
@onready var cancel_button = $ColorOptions/CancelButton
@onready var previous_selected_rect = $PreviousSelectedRect
@onready var current_selected_rect = $CurrentSelectedRect
@onready var color_grid = $ColorGrid
static var recent_colors = [Color("#888888"), Color("#555555"), Color("#888888"), Color("#555555"), Color("#888888"), Color("#555555"), 
Color("#888888"), Color("#555555"), Color("#888888"), Color("#555555"), Color("#888888"), Color("#555555")]
var sample_colors = [Color("000000"), Color("333333"), Color("666666"), Color("999999"), Color("CCCCCC"), Color("FFFFFF"), 
Color("FF0000"), Color("00FF00"), Color("0000FF"), Color("FFFF00"), Color("00FFFF"), Color("FF00FF")]
var columns = 18
var rows = 12
var chunk = 6
var previous_color = Color("000000")
var current_color = Color("000000")
var old_hex_code: String


func _ready() -> void:
	hsv_rectangle.color_changed.connect(_set_color)
	rgb_sliders.color_changed.connect(_set_color)
	hex_code.text = "0x" + current_color.to_html(false)
	old_hex_code = hex_code.text
	hex_code.text_changed.connect(_check_hex_code)
	ok_button.pressed.connect(_ok_pressed)
	cancel_button.pressed.connect(_cancel_pressed)
	init()


func _process(_delta: float) -> void:
	check_buttons()


func init() -> void:
	for child in color_grid.get_children():
		child.queue_free()
	color_grid.columns = columns + 4
	var color = Color(0, 0, 0, 1)
	for y in rows:
		var recent_color = recent_colors[y] if y < recent_colors.size() else Color(0, 0, 0, 1)
		create_color_button(recent_color, "recent" + str(y))
		create_color_button(Color(0, 0, 0, 1), "recentblack" + str(y))
		var sample_color = sample_colors[y] if y < sample_colors.size() else Color(0, 0, 0, 1)
		create_color_button(sample_color, "sample" + str(y))
		create_color_button(Color(0, 0, 0, 1), "sampleblack" + str(y))
		if y < rows / 2:
			color.r = 0
		else:
			color.r = (1 / (float(chunk) - 1)) * (chunk / 2)
		color.g = 0
		if y != 0:
			if color.b >= 1:
				color.b = 0
			else:
				color.b += 1 / (float(chunk) - 1)
		for x in columns:
			if x != 0:
				if color.g >= 1:
					color.r += 1 / (float(chunk) - 1)
					color.g = 0
				else:
					color.g += 1 / (float(chunk) - 1)
			create_color_button(color, "color" + str((rows * y) + (x + 1)))


func create_color_button(button_color: Color, button_name: String = ""):
	var colornode = Control.new()
	colornode.size = Vector2(20, 20)
	colornode.custom_minimum_size = Vector2(20, 20)
	if button_name:
		colornode.name = button_name
	var blackoutline = ReferenceRect.new()
	blackoutline.border_color = Color(0, 0, 0, 1)
	blackoutline.size = Vector2(20, 20)
	blackoutline.editor_only = false
	var gradient = Gradient.new()
	gradient.set_colors(PackedColorArray([button_color]))
	var texture = GradientTexture1D.new()
	texture.gradient = gradient
	var colorbutton = TextureButton.new()
	colorbutton.ignore_texture_size = true
	colorbutton.stretch_mode = 0
	colorbutton.texture_normal = texture
	colorbutton.size = Vector2(20, 20)
	colorbutton.show_behind_parent = true
	colorbutton.pressed.connect(_set_new_color.bind(button_color))
	colornode.add_child(blackoutline)
	colornode.add_child(colorbutton)
	color_grid.add_child(colornode)


func set_previous_color(new_color: Color):
	previous_color = new_color
	if previous_color not in recent_colors:
		recent_colors.pop_back()
		recent_colors.push_front(previous_color)
	set_previous_color_rect()


func set_previous_color_rect():
	previous_selected_rect.visible = false
	var previous_selected_color = null
	for child in color_grid.get_children():
		for node in child.get_children():
			if node is TextureButton and previous_selected_color == null and (!node.name.contains("recent") and !node.name.contains("sample")):
				var node_color = node.texture_normal.gradient.get_colors()
				if node_color[0] == previous_color:
					previous_selected_color = node_color[0]
					previous_selected_rect.visible = true
					previous_selected_rect.position = color_grid.position + node.get_parent().position
					break
		if previous_selected_color != null:
			break


func check_buttons() -> void:
	current_selected_rect.visible = false
	var selected_button = null
	for child in color_grid.get_children():
		for node in child.get_children():
			if node is TextureButton and node.is_hovered() and selected_button == null:
				selected_button = node
				current_selected_rect.visible = true
				current_selected_rect.position = color_grid.position + node.get_parent().position


func _check_hex_code(new_hex_code: String):
	if !new_hex_code.is_empty() and new_hex_code.is_valid_hex_number(false):
		new_hex_code = new_hex_code.rpad(6, "0") + "FF"
		var converted_color = Color.from_string(new_hex_code, 0x000000FF)
		_set_color(converted_color, false, false)
	else:
		var lowercase_hex_code = new_hex_code.to_lower().rpad(8, "0") + "FF"
		if !lowercase_hex_code.is_empty() and lowercase_hex_code.begins_with("0x") and lowercase_hex_code.is_valid_hex_number(true):
			var color_string = new_hex_code.substr(2, -1)
			if !color_string.is_empty():
				color_string = color_string.rpad(6, "0") + "FF"
				var converted_color = Color.from_string(color_string, 0x000000FF)
				_set_color(converted_color, true, false)
		elif !new_hex_code.is_empty():
			var cursor_position = hex_code.get_caret_column()
			hex_code.text = old_hex_code
			hex_code.caret_column = cursor_position
		else:
			hex_code.text = ""
			old_hex_code = hex_code.text


func _ok_pressed():
	_set_new_color(current_color)


func _set_color(new_color: Color, show_starting_hex: bool = true, change_hex_code: bool = true):
	hsv_rectangle.color = new_color
	rgb_sliders.color = new_color
	if change_hex_code:
		if show_starting_hex:
			hex_code.text = "0x" + new_color.to_html(false)
		else:
			hex_code.text = new_color.to_html(false)
	old_hex_code = hex_code.text
	current_color = new_color
	if previous_selected_rect.visible:
		previous_selected_rect.visible = false


func _set_new_color(new_color: Color):
	_set_color(new_color, true, true)
	emit_signal("set_new_color", new_color)


func _cancel_pressed():
	get_parent().visible = false
