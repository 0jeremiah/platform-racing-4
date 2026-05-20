extends Control

signal change_selected_background

@onready var bg_picker_panel = $BGPickerPanel
@onready var navigation = $Navigation
@onready var light_color_rect = $LightColorRect
@onready var dark_color_rect = $DarkColorRect
@onready var bg_button_container = $BGButtonContainer
@onready var no_bgs_text = $NoBGsText
@onready var color_box = preload("res://ui/colorbutton.tscn")

var graphic_array: Array
var xoffset: float = 30
var yoffset: float = 88
var background_graphics: Array = []
var background_array: Array = []
var bg_picker_pages: int = 1
var bg_picker_page: int = 1
var current_bg_graphics: Array = []
var current_bg_array: Array = []


func _ready() -> void:
	for bg_graphic in Backgrounds.bg_graphic_list:
		background_graphics.append(bg_graphic)
	background_graphics.push_front("ColorBox")
	for bg_array in Backgrounds.bg_list:
		background_array.append(bg_array)
	background_array.push_front("ColorBox")
	navigation.set_align("right")
	navigation.connect("set_page", _on_set_page)
	show_bgs()


func _process(_delta: float) -> void:
	for child in bg_button_container.get_children():
		_check_clicked_button(child)


func _check_clicked_button(node: Node):
	if node.get_parent().name != "ColorBox" and (node is TextureButton or node is Button):
		if node.visible and node.is_hovered() and !node.is_pressed():
			node.scale = Vector2(1.25, 1.25)
		else:
			node.scale = Vector2(1, 1)


func show_bgs():
	graphic_array = background_graphics
	current_bg_graphics = []
	current_bg_array = []
	# print(tab_bar.current_tab)
	for child in bg_button_container.get_children():
		child.free()
	bg_picker_pages = 1
	var page_counter: int = 1
	var full_bg_graphics = background_graphics
	var full_bg_array = background_array
	while (15 * page_counter) < background_graphics.size():
		bg_picker_pages += 1
		page_counter += 1
	current_bg_graphics = full_bg_graphics.slice((15 * (bg_picker_page - 1)), (15 * bg_picker_page))
	current_bg_array = full_bg_array.slice((15 * (bg_picker_page - 1)), (15 * bg_picker_page))
	navigation.init(bg_picker_page, bg_picker_pages, 4, true)
	if !current_bg_graphics.is_empty():
		no_bgs_text.visible = false
		navigation.init(bg_picker_page, bg_picker_pages, 4, true)
		for graphic in current_bg_graphics.size():
			if current_bg_graphics[graphic] is String:
				var bg_color_button = color_box.instantiate()
				bg_color_button.size = Vector2(48, 48)
				bg_color_button.position = Vector2(68 * snapped((graphic % 5), 1), 68 * snapped((graphic / 5), 1))
				bg_color_button.pivot_offset = Vector2(bg_color_button.size.x / 2, bg_color_button.size.y / 2)
				bg_color_button.name = "ColorBox"
				bg_color_button.spawn_x = bg_color_button.size.x
				bg_button_container.add_child(bg_color_button)
				bg_color_button.set_color("BBBBDDFF")
				bg_color_button.colorbutton_color_changed.connect(_set_bg.bind())
			else:
				var graphicbutton = TextureButton.new()
				graphicbutton.texture_normal = current_bg_graphics[graphic]
				graphicbutton.ignore_texture_size = true
				graphicbutton.stretch_mode = 0
				graphicbutton.size = Vector2(48, 48)
				graphicbutton.position = Vector2(68 * snapped((graphic % 5), 1), 68 * snapped((graphic / 5), 1))
				graphicbutton.pivot_offset = Vector2(graphicbutton.size.x / 2, graphicbutton.size.y / 2)
				graphicbutton.name = "BGButton" + str(graphic)
				bg_button_container.add_child(graphicbutton)
				graphicbutton.pressed.connect(_set_bg.bind(Color("FFFFFF"), current_bg_array[graphic]))
			bg_picker_panel.size = Vector2(380, yoffset + ((68 * (snapped((graphic / 5), 1) + 1)) + 20))
			bg_button_container.size = Vector2(320, (68 * (snapped((graphic / 5), 1) + 1)) - 20)
	else:
		no_bgs_text.visible = true
		navigation.init(1, 0, 3, false)
		bg_picker_panel.size = Vector2(380, yoffset + 88)
		bg_button_container.size = Vector2(320, 48)
	light_color_rect.size = Vector2(bg_button_container.size.x + 20, bg_button_container.size.y + 20)
	light_color_rect.position = Vector2(bg_button_container.position.x - 10, bg_button_container.position.y - 10)
	dark_color_rect.size = Vector2(bg_button_container.size.x + 30, bg_button_container.size.y + 30)
	dark_color_rect.position = Vector2(bg_button_container.position.x - 15, bg_button_container.position.y - 15)
	bg_button_container.position = Vector2(xoffset, yoffset)
	size = bg_picker_panel.size


func _set_bg(new_bg_color: Color, new_bg_id: String = "blank"):
	var bg_color = new_bg_color
	var bg_id = new_bg_id
	emit_signal("change_selected_background", [bg_color, bg_id])


func _on_set_page(new_page_number: int):
	_set_page(false, clamp(new_page_number, 1, bg_picker_pages))


func _set_page(incordec: bool, new_page_number: int):
	if incordec:
		bg_picker_page += new_page_number
	else:
		bg_picker_page = new_page_number
	show_bgs()
