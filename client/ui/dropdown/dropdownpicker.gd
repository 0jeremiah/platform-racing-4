extends Control

signal dropdown_selected

@onready var scroll_container = $ScrollContainer
@onready var dropdown_container = $ScrollContainer/DropdownContainer

const DROPDOWN_ROW = preload("res://ui/dropdown/dropdownrow.tscn")

var dropdown_size: Vector2 = Vector2(200.0, 200.0)
var scrollbar_width: float = 12.0


func _ready():
	render()


func render():
	var current_size: Vector2 = Vector2(40, 40)
	if dropdown_size.x >= 40.0:
		current_size.x = dropdown_size.x
	if dropdown_size.y >= 40.0:
		current_size.y = dropdown_size.y
	#dropdown_panel.size = Vector2(current_size.x + (padding_size.x * 2), current_size.y + (padding_size.y * 2))
	size = Vector2(current_size.x, current_size.y)
	scroll_container.size = Vector2(current_size.x, current_size.y)


func clear(immediately_render: bool = false):
	for child in dropdown_container.get_children():
		child.free()
	if immediately_render:
		render()


func add_options_from_dictionary(options_dictionary: Dictionary):
	for option in options_dictionary:
		var label = "null"
		if option.has("label"):
			label = option.label
		var data = null
		if option.has("data"):
			data = option.data
		add_option(label, data)


func add_options_from_array(options_array: Array):
	for option in options_array:
		if option is Dictionary:
			var label = "null"
			if option.has("label"):
				label = option.label
			var data = null
			if option.has("data"):
				data = option.data
			add_option(label, data)


func add_option(new_label: String, new_data = null, immediately_render: bool = false):
	var new_option = DROPDOWN_ROW.instantiate()
	new_option.set_button(new_label, new_data)
	new_option.pressed.connect(_selected_dropdown.bind(new_option.data))
	new_option.custom_minimum_size = Vector2(dropdown_size.x - scrollbar_width, 30)
	dropdown_container.add_child(new_option)
	if immediately_render:
		render()


func _selected_dropdown(selected_data = null):
	emit_signal("dropdown_selected", selected_data)


func set_dropdown_size(new_size: Vector2):
	if new_size.x >= 40.0:
		dropdown_size.x = new_size.x
	if new_size.y >= 40.0:
		dropdown_size.y = new_size.y
	render()
