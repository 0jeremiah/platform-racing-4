extends Control

signal jump_menu_option_chosen

@onready var jump_menu_container = $JumpMenuContainer

var jump_menu_button = preload("res://ui/jump_menu/jump_menu_button.tscn")
var jump_menu_width: float = 200.0


func _ready() -> void:
	init()


func init():
	create_separator()
	create_button("Never Mind", null)


func _process(_delta: float) -> void:
	if jump_menu_container:
		size = jump_menu_container.size


func create_button(button_text: String, button_func = null):
	var button = jump_menu_button.instantiate()
	button.custom_minimum_size = Vector2(jump_menu_width, 30.0)
	button.size = Vector2(jump_menu_width, 30.0)
	jump_menu_container.add_child(button)
	button.set_button(button_text, button_func)
	button.pressed.connect(_call_button_func.bind(button.button_func))
	if jump_menu_container.get_child_count() > 2:
		jump_menu_container.move_child(button, jump_menu_container.get_child_count() - 3)


func create_separator():
	var separator = HSeparator.new()
	separator.custom_minimum_size = Vector2(jump_menu_width, 10.0)
	separator.size = Vector2(jump_menu_width, 10.0)
	jump_menu_container.add_child(separator)
	if jump_menu_container.get_child_count() > 2:
		jump_menu_container.move_child(separator, jump_menu_container.get_child_count() - 3)


func _call_button_func(button_callable = null):
	emit_signal("jump_menu_option_chosen", button_callable)
