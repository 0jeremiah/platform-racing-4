extends Popup

signal return_dropdown_data

@onready var dropdown_picker = $DropdownPicker

var spawn_x: float = 0
var spawn_y: float = 0
var holder = null


func _ready():
	dropdown_picker.dropdown_selected.connect(_send_dropdown_data)


func clear():
	dropdown_picker.clear()


func add_options(options_dictionary: Dictionary):
	for option in options_dictionary:
		var label = "null"
		if option.has("label"):
			label = option.label
		var data = null
		if option.has("data"):
			data = option.data
		dropdown_picker.add_option(label, data)


func add_option(new_label: String, new_data = null):
	dropdown_picker.add_option(new_label, new_data)


func show_popup(_spawn_x: float = spawn_x, _spawn_y: float = spawn_y):
	dropdown_picker.render()
	popup(Rect2(_spawn_x, _spawn_y, dropdown_picker.dropdown_panel.size.x, dropdown_picker.dropdown_panel.size.y))


func _send_dropdown_data(dropdown_data = null):
	emit_signal("return_dropdown_data", dropdown_data)
	hide()
	holder = null


func set_dropdown_size(new_size: Vector2):
	var current_size: Vector2 = Vector2(40, 40)
	if new_size.x >= 40.0:
		current_size.x = new_size.x
	if new_size.y >= 40.0:
		current_size.y = new_size.y
	dropdown_picker.set_dropdown_size(current_size.x, current_size.y)


func set_padding_size(new_padding_size: Vector2):
	var current_padding_size: Vector2 = Vector2(40, 40)
	if new_padding_size.x >= 0.0:
		current_padding_size.x = new_padding_size.x
	if new_padding_size.y >= 0.0:
		current_padding_size.y = new_padding_size.y
	dropdown_picker.set_padding_size(current_padding_size.x, current_padding_size.y)
