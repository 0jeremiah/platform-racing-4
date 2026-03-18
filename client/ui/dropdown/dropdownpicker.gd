extends Control

signal dropdown_selected

@onready var dropdown_panel = $DropdownPanel
@onready var scroll_container = $ScrollContainer
@onready var dropdown_container = $ScrollContainer/DropdownContainer

const DROPDOWN_ROW = preload("res://ui/dropdown/dropdownrow.tscn")

var dropdown_size: Vector2 = Vector2(200.0, 200.0)
var padding_size: Vector2 = Vector2(20.0, 20.0)
var scrollbar_width: float = 12.0


func _ready():
	render()


func render():
	var current_size: Vector2 = Vector2(40, 40)
	if dropdown_size.x >= 40.0:
		current_size.x = dropdown_size.x
	if dropdown_size.y >= 40.0:
		current_size.y = dropdown_size.y
	dropdown_panel.size = Vector2(current_size.x + (padding_size.x * 2), current_size.y + (padding_size.y * 2))
	scroll_container.size = Vector2(current_size.x, current_size.y)
	scroll_container.position = Vector2(padding_size.x, padding_size.y)
	for child in dropdown_container.get_children():
		child.custom_minimum_size = Vector2(scroll_container.size.x - scrollbar_width, 30)


func clear(immediately_render: bool = false):
	for child in dropdown_container.get_children():
		child.free()
	if immediately_render:
		render()


func add_option(new_label: String, new_data = null, immediately_render: bool = false):
	var new_option = DROPDOWN_ROW.instantiate()
	new_option.set_button(new_label, new_data)
	new_option.pressed.connect(_selected_dropdown.bind(new_option.data))
	dropdown_container.add_child(new_option)
	if immediately_render:
		render()


func _selected_dropdown(selected_data = null):
	emit_signal("dropdown_selected", selected_data)


func set_dropdown_size(new_size_x: float, new_size_y: float):
	if new_size_x >= 40.0:
		dropdown_size.x = new_size_x
	if new_size_y >= 40.0:
		dropdown_size.y = new_size_y
	render()


func set_padding_size(new_padding_x: float, new_padding_y: float):
	if new_padding_x >= 0.0:
		dropdown_size.x = new_padding_x
	if new_padding_y >= 0.0:
		dropdown_size.y = new_padding_y
	render()
