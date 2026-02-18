extends Control

signal change_selected_stamp

@onready var stamp_picker_panel = $StampPickerPanel
@onready var tab_bar = $TabBar
@onready var navigation = $Navigation
@onready var light_color_rect = $LightColorRect
@onready var dark_color_rect = $DarkColorRect
@onready var stamp_button_container = $StampButtonContainer
@onready var no_stamps_text = $NoStampsText

var graphic_array: Array
var xoffset: float = 30
var yoffset: float = 139
var stamp_container: Stamps = Stamps.new()
var stamp_graphics: Array = []
var stamp_array: Array = []
var current_tab: int
var stamp_picker_pages: int = 1
var stamp_picker_page: int = 1
var current_stamp_graphics: Array = []
var current_stamp_array: Array = []
var custom_stamp_list: Array = []


func _ready() -> void:
	stamp_graphics = stamp_container.stamp_graphic_list
	stamp_array = stamp_container.stamp_list
	navigation.set_align("right")
	navigation.connect("set_page", _on_set_page)
	show_bgs()


func _physics_process(delta: float) -> void:
	if current_tab != tab_bar.current_tab:
		show_bgs()
	current_tab = tab_bar.current_tab
	for child in stamp_button_container.get_children():
		_check_clicked_button(child)


func _check_clicked_button(node: Node):
	if node.get_parent().name != "ColorBox" and (node is TextureButton or node is Button):
		if node.visible and node.is_hovered() and !node.is_pressed():
			node.scale = Vector2(1.25, 1.25)
		else:
			node.scale = Vector2(1, 1)


func show_bgs():
	graphic_array = stamp_graphics
	current_stamp_graphics = []
	current_stamp_array = []
	for child in stamp_button_container.get_children():
		child.free()
	stamp_picker_pages = 1
	var page_counter: int = 1
	if tab_bar.current_tab == 1:
		pass # custom stamps code goes here
	else:
		var full_stamp_graphics = stamp_graphics
		var full_stamp_array = stamp_array
		while (15 * page_counter) < stamp_graphics.size():
			stamp_picker_pages += 1
			page_counter += 1
		current_stamp_graphics = full_stamp_graphics.slice((15 * (stamp_picker_page - 1)), (15 * stamp_picker_page))
		current_stamp_array = full_stamp_array.slice((15 * (stamp_picker_page - 1)), (15 * stamp_picker_page))
		navigation.init(stamp_picker_page, stamp_picker_pages, 4, true)
	if !current_stamp_graphics.is_empty():
		no_stamps_text.visible = false
		navigation.init(stamp_picker_page, stamp_picker_pages, 4, true)
		for graphic in current_stamp_graphics.size():
			var graphicbutton = TextureButton.new()
			graphicbutton.texture_normal = current_stamp_graphics[graphic]
			graphicbutton.ignore_texture_size = true
			graphicbutton.stretch_mode = 5
			graphicbutton.size = Vector2(48, 48)
			graphicbutton.position = Vector2(68 * snapped((graphic % 5), 1), 68 * snapped((graphic / 5), 1))
			graphicbutton.pivot_offset = Vector2(graphicbutton.size.x / 2, graphicbutton.size.y / 2)
			graphicbutton.name = "StampButton" + str(graphic)
			stamp_button_container.add_child(graphicbutton)
			graphicbutton.pressed.connect(_set_stamp.bind(current_stamp_array[graphic]))
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
	show_bgs()
