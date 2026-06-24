extends Control

signal change_selected_background

@onready var bg_picker_panel = $BGPickerPanel
@onready var navigation = $Navigation
@onready var light_color_rect = $LightColorRect
@onready var dark_color_rect = $DarkColorRect
@onready var bg_button_container = $BGButtonContainer
@onready var no_bgs_text = $NoBGsText
@onready var color_box = preload("res://ui/colorbutton.tscn")

var xoffset: float = 30
var yoffset: float = 88
var bg_dictionary: Dictionary = {}
var bg_picker_pages: int = 1
var bg_picker_page: int = 1
var current_bg_dictionary: Dictionary = {}
var custom_bg_dictionary: Dictionary = {}


func _ready() -> void:
	bg_dictionary.clear()
	for bg in Backgrounds.bg_dictionary:
		bg_dictionary[bg] = {"id": bg, "texture": Backgrounds.bg_dictionary[bg].texture}
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
	bg_dictionary.clear()
	for bg in Backgrounds.bg_dictionary:
		bg_dictionary[bg] = {"id": bg, "texture": Backgrounds.bg_dictionary[bg].texture}
	current_bg_dictionary.clear()
	var bg_dictionary_keys = bg_dictionary.keys()
	for child in bg_button_container.get_children():
		child.free()
	bg_picker_pages = 1
	var page_counter: int = 1
	while (15 * page_counter) < bg_dictionary_keys.size():
		bg_picker_pages += 1
		page_counter += 1
	bg_dictionary_keys = bg_dictionary_keys.slice((15 * (bg_picker_page - 1)), (15 * bg_picker_page))
	for bg in bg_dictionary_keys:
		current_bg_dictionary[bg] = {"id": bg, "texture": bg_dictionary[bg].texture}
	navigation.init(bg_picker_page, bg_picker_pages, 4, true)
	if !current_bg_dictionary.is_empty():
		no_bgs_text.visible = false
		navigation.init(bg_picker_page, bg_picker_pages, 4, true)
		for bg in current_bg_dictionary.size():
			if bg_dictionary_keys[bg] == "blank":
				var bg_color_button = color_box.instantiate()
				bg_color_button.size = Vector2(48, 48)
				bg_color_button.position = Vector2(68 * snapped((bg % 5), 1), 68 * snapped((bg / 5), 1))
				bg_color_button.pivot_offset = Vector2(bg_color_button.size.x / 2, bg_color_button.size.y / 2)
				bg_color_button.name = "ColorBox"
				bg_color_button.spawn_x = bg_color_button.size.x
				bg_button_container.add_child(bg_color_button)
				bg_color_button.set_color("BBBBDDFF")
				bg_color_button.colorbutton_color_changed.connect(_set_bg.bind())
			else:
				var graphicbutton = TextureButton.new()
				graphicbutton.texture_normal = current_bg_dictionary[bg_dictionary_keys[bg]].texture
				graphicbutton.ignore_texture_size = true
				graphicbutton.stretch_mode = 0
				graphicbutton.size = Vector2(48, 48)
				graphicbutton.position = Vector2(68 * snapped((bg % 5), 1), 68 * snapped((bg / 5), 1))
				graphicbutton.pivot_offset = Vector2(graphicbutton.size.x / 2, graphicbutton.size.y / 2)
				graphicbutton.name = "BGButton" + str(bg)
				bg_button_container.add_child(graphicbutton)
				graphicbutton.pressed.connect(_set_bg.bind(Color("FFFFFF"), current_bg_dictionary[bg_dictionary_keys[bg]].id))
			bg_picker_panel.size = Vector2(380, yoffset + ((68 * (snapped((bg / 5), 1) + 1)) + 20))
			bg_button_container.size = Vector2(320, (68 * (snapped((bg / 5), 1) + 1)) - 20)
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
	var bg_color = new_bg_color.to_html(false)
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
