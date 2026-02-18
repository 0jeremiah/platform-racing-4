extends Control

@onready var label_text = $LabelText
@onready var edit_text_color_rect = $EditTextColorRect
@onready var edit_text_rect = $EditTextRect
@onready var edit_text = $EditText
@onready var select_rect = $SelectRect
@onready var buttons = $Buttons
@onready var example_node = $Sprite2D
var delete_enabled: bool = true
var resize_enabled: bool = true
var options_enabled: bool = true
var font_options_enabled: bool = false
var editing_enabled: bool = false
var color_editing_enabled: bool = false
var button_colors: Array = [Color("ff4b00"), Color("1fcf1f"), Color("ff8a21"), Color("00cade"),
Color("7b31f9"), Color("FFFFFF")]
var position_list: Array = [Vector2(0, 1), Vector2(1, 1), Vector2(1, 0), Vector2(0, 0), Vector2(0.5, 0),
Vector2(0, 0.5), Vector2(1, 0.5), Vector2(0.5, 1)]
var object_info: Dictionary = {"node": example_node, "position": Vector2(0, 0), "size": Vector2(64, 64),
"scale": Vector2(1, 1), "text": null, "color": null, "options": null}
var mode : String = "idle"
var old_position : Vector2
var old_scale : Vector2
var old_mouse_position : Vector2


func _ready() -> void:
	position_buttons()


func _process(delta: float) -> void:
	if object_info.text != null:
		select_rect.size = Vector2(edit_text.size.x * abs(edit_text.scale.x), edit_text.size.y * abs(edit_text.scale.y))
		select_rect.scale = Vector2(abs(edit_text.scale.x) / edit_text.scale.x, abs(edit_text.scale.y) / edit_text.scale.y)
		label_text.text = edit_text.text
		label_text.size = select_rect.size
		label_text.scale = select_rect.scale
		edit_text_color_rect.size = select_rect.size
		edit_text_color_rect.scale = select_rect.scale
		edit_text_rect.size = select_rect.size
		edit_text_rect.scale = select_rect.scale
	else:
		select_rect.size = object_info.size
		select_rect.scale = object_info.scale
	process_buttons()


func set_object_info(new_node = null, new_position = null, new_size = null, new_scale = null, new_color = null, new_options = null):
	if new_node:
		object_info.node = new_node
	if new_position and new_position is Vector2:
		object_info.position = new_position
	if new_size and new_size is Vector2:
		object_info.size = new_size
	if new_scale and new_scale is Vector2:
		object_info.scale = new_scale
	if new_color and new_color is Color:
		object_info.color = new_color
	if new_options:
		object_info.options = new_options

func resize() -> void:
	if mode != "resize":
		old_position = object_info.position
		old_scale = object_info.scale
		old_mouse_position = get_local_mouse_position()
	mode == "resize"
	var scale_x: float = old_scale.x / (old_mouse_position.x / get_local_mouse_position().x)
	var scale_y: float = old_scale.y / (old_mouse_position.y / get_local_mouse_position().y)
	if Input.is_action_pressed("shift"):
		if scale_x >= scale_y:
			resize_text(scale_x, scale_x)
		else:
			resize_text(scale_y, scale_y)
	else:
		resize_text(scale_x, scale_y)


func resize_text(width, height):
	edit_text.scale.x = width
	edit_text.scale.y = height
	label_text.scale = edit_text.scale


func process_buttons() -> void:
	for button_node in buttons.get_child_count():
		for button in buttons.get_child(button_node).get_children():
			if button.name != "ColorButton" and button is Button:
				var node
				if button.is_hovered() and !button.button_pressed:
					if buttons.get_child(button_node).has_node("SmallColorRect"):
						node = buttons.get_child(button_node).get_node("SmallColorRect")
						node.scale = Vector2(1.5, 1.5)
					if buttons.get_child(button_node).has_node("LargeColorRect"):
						node = buttons.get_child(button_node).get_node("LargeColorRect")
						node.color = button_colors[button_node]
						node.scale = Vector2(1.5, 1.5)
					if buttons.get_child(button_node).has_node("SmallTexture"):
						node = buttons.get_child(button_node).get_node("SmallTexture")
						node.visible = false
					if buttons.get_child(button_node).has_node("LargeTexture"):
						node = buttons.get_child(button_node).get_node("LargeTexture")
						node.self_modulate = Color("000000")
						node.visible = true
					button.scale = Vector2(1.5, 1.5)
				else:
					if buttons.get_child(button_node).has_node("SmallColorRect"):
						node = buttons.get_child(button_node).get_node("SmallColorRect")
						node.scale = Vector2(1, 1)
					if buttons.get_child(button_node).has_node("LargeColorRect"):
						node = buttons.get_child(button_node).get_node("LargeColorRect")
						node.color = Color("7f7f7f")
						node.scale = Vector2(1, 1)
					if buttons.get_child(button_node).has_node("SmallTexture"):
						node = buttons.get_child(button_node).get_node("SmallTexture")
						node.self_modulate = button_colors[button_node]
						node.visible = true
					if buttons.get_child(button_node).has_node("LargeTexture"):
						node = buttons.get_child(button_node).get_node("LargeTexture")
						node.visible = false
					button.scale = Vector2(1, 1)


func position_buttons() -> void:
	var button_counter: int = 0
	var enabled_list: Array = [delete_enabled, resize_enabled, options_enabled, font_options_enabled,
	editing_enabled, color_editing_enabled]
	for button in buttons.get_child_count():
		if enabled_list[button]:
			buttons.get_child(button).position = Vector2(select_rect.size.x * position_list[button_counter].x - buttons.get_child(button).size.x / 2, select_rect.size.y * position_list[button_counter].y - buttons.get_child(button).size.y / 2)
			buttons.get_child(button).visible = true
			button_counter += 1
		else:
			buttons.get_child(button).visible = false
