extends Control

signal change_selected_stamp

@onready var stamp_picker_panel = $StampPickerPanel
@onready var tab_bar = $TabBar
@onready var navigation = $Navigation
@onready var light_color_rect = $LightColorRect
@onready var dark_color_rect = $DarkColorRect
@onready var stamp_button_container = $StampButtonContainer
@onready var no_stamps_text = $NoStampsText

var xoffset: float = 30
var yoffset: float = 139
var stamp_dictionary: Dictionary = {}
var current_tab: int
var stamp_picker_pages: int = 1
var stamp_picker_page: int = 1
var current_stamp_dictionary: Dictionary = {}
var custom_stamp_dictionary: Dictionary = {}


func _ready() -> void:
	stamp_dictionary.clear()
	for stamp in Stamps.stamp_dictionary:
		stamp_dictionary[stamp] = {"id": stamp, "texture": Stamps.stamp_dictionary[stamp].texture}
	navigation.set_align("right")
	navigation.connect("set_page", _on_set_page)
	tab_bar.tab_changed.connect(show_stamps)
	show_stamps()


func _process(_delta: float) -> void:
	for child in stamp_button_container.get_children():
		_check_clicked_button(child)


func _check_clicked_button(node: Node):
	if node.get_parent().name != "ColorBox" and (node is TextureButton or node is Button):
		if node.visible and node.is_hovered():
			if node.is_pressed():
				node.scale = Vector2(1, 1)
				node.self_modulate = Color(0.75, 0.75, 0.75)
			else:
				node.scale = Vector2(1.25, 1.25)
				node.self_modulate = Color(1.25, 1.25, 1.25)
		else:
			node.scale = Vector2(1, 1)
			node.self_modulate = Color(1, 1, 1)


func show_stamps():
	stamp_dictionary.clear()
	for stamp in Stamps.stamp_dictionary:
		stamp_dictionary[stamp] = {"id": stamp, "texture": Stamps.stamp_dictionary[stamp].texture}
	current_stamp_dictionary.clear()
	var stamp_dictionary_keys = stamp_dictionary.keys()
	for child in stamp_button_container.get_children():
		child.free()
	stamp_picker_pages = 1
	var page_counter: int = 1
	if tab_bar.current_tab == 1:
		pass # custom stamps code goes here
	else:
		while (15 * page_counter) < stamp_dictionary_keys.size():
			stamp_picker_pages += 1
			page_counter += 1
		stamp_dictionary_keys = stamp_dictionary_keys.slice((15 * (stamp_picker_page - 1)), (15 * stamp_picker_page))
		for stamp in stamp_dictionary_keys:
			current_stamp_dictionary[stamp] = {"id": stamp, "texture": stamp_dictionary[stamp].texture}
		navigation.init(stamp_picker_page, stamp_picker_pages, 4, true)
	if !current_stamp_dictionary.is_empty():
		no_stamps_text.visible = false
		navigation.init(stamp_picker_page, stamp_picker_pages, 4, true)
		for graphic in current_stamp_dictionary.size():
			var graphicbutton = TextureButton.new()
			graphicbutton.texture_normal = current_stamp_dictionary[stamp_dictionary_keys[graphic]].texture
			graphicbutton.ignore_texture_size = true
			graphicbutton.stretch_mode = 5
			graphicbutton.size = Vector2(48, 48)
			graphicbutton.position = Vector2(68 * snapped((graphic % 5), 1), 68 * snapped((graphic / 5), 1))
			graphicbutton.pivot_offset = Vector2(graphicbutton.size.x / 2, graphicbutton.size.y / 2)
			graphicbutton.name = "StampButton" + str(graphic)
			stamp_button_container.add_child(graphicbutton)
			graphicbutton.pressed.connect(_set_stamp.bind(current_stamp_dictionary[stamp_dictionary_keys[graphic]].id))
			stamp_picker_panel.size = Vector2(380, yoffset + ((68 * (snapped((graphic / 5), 1) + 1)) + 20))
			stamp_button_container.size = Vector2(320, (68 * (snapped((graphic / 5), 1) + 1)) - 20)
	else:
		no_stamps_text.visible = true
		navigation.init(1, 0, 3, false)
		stamp_picker_panel.size = Vector2(380, yoffset + 88)
		stamp_button_container.size = Vector2(320, 48)
	light_color_rect.size = Vector2(stamp_button_container.size.x + 20, stamp_button_container.size.y + 20)
	light_color_rect.position = Vector2(stamp_button_container.position.x - 10, stamp_button_container.position.y - 10)
	dark_color_rect.size = Vector2(stamp_button_container.size.x + 30, stamp_button_container.size.y + 30)
	dark_color_rect.position = Vector2(stamp_button_container.position.x - 15, stamp_button_container.position.y - 15)
	stamp_button_container.position = Vector2(xoffset, yoffset)
	size = stamp_picker_panel.size


func _set_stamp(id: String = "cactus"):
	var stamp_id = id
	emit_signal("change_selected_stamp", stamp_id)


func _on_set_page(new_page_number: int):
	_set_page(false, clamp(new_page_number, 1, stamp_picker_pages))


func _set_page(incordec: bool, new_page_number: int):
	if incordec:
		stamp_picker_page += new_page_number
	else:
		stamp_picker_page = new_page_number
	show_stamps()
