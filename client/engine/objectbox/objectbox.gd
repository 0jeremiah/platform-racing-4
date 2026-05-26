extends Control

signal object_moved
signal object_deleted
signal object_resized
signal object_edited
signal object_options_changed

@onready var gui_touchbox = $GUITouchbox # is here so cursor touches gui and doesn't act weird.
@onready var select_rect = $SelectRect
@onready var move_button = $MoveButton
@onready var edit_text_color_rect = $EditTextColorRect
@onready var edit_text_rect = $EditTextRect
@onready var edit_text = $EditText
@onready var buttons = $Buttons

var delete_enabled: bool = true
var resize_enabled: bool = true
var options_enabled: bool = true
var edit_enabled: bool = true
var button_list: Array = [delete_enabled, resize_enabled, options_enabled, edit_enabled]
var enabled_list: Array = [true, true, true, true]
var button_colors: Array = [Color("ff4b00"), Color("1fcf1f"), Color("ff8a21"), Color("7b31f9")]
var position_list: Array = [Vector2(0, 1), Vector2(1, 1), Vector2(1, 0), Vector2(0, 0)]
var object_info: Dictionary = {"type": "", "node": null, "position": Vector2(0, 0), "rotation": 0,
"offset": Vector2(0, 0), "size": Vector2(0, 0), "scale": Vector2(0, 0), "text": null, "info": null}
var extra_object_info: Dictionary = {}
var mode : String = "idle"
var old_position : Vector2
var old_scale : Vector2
var old_mouse_position : Vector2


#set_object_info({"delete": true, "resize": false, "options": true, "edit": false}, {"type": "block",
	#"node": example_node, "position": example_node.position, "rotation": example_node.rotation_degrees,
	#"offset": example_node.offset, "size": example_node.texture.region.size, "scale": example_node.scale})


func _ready() -> void:
	for button_node in buttons.get_child_count():
		for button in buttons.get_child(button_node).get_children():
			if button is Button:
				if button.get_parent().name == "DeleteButton":
					button.button_down.connect(delete_object)
				elif button.get_parent().name == "ResizeButton":
					button.button_down.connect(resize_object)
				elif button.get_parent().name == "EditButton":
					button.button_down.connect(edit_object)
				elif button.get_parent().name == "OptionsButton":
					button.button_down.connect(show_object_options)
	move_button.button_down.connect(move_object)


func _physics_process(_delta: float) -> void:
	var camera = get_viewport().get_camera_2d()
	if camera:
		gui_touchbox.size = get_viewport().get_visible_rect().size / camera.zoom
		gui_touchbox.global_position = camera.get_screen_center_position() - ((get_viewport().get_visible_rect().size / 2) / camera.zoom)
	gui_touchbox.visible = false
	if object_info.type != "block" and (mode == "move" or mode == "resize"):
		gui_touchbox.visible = true
	if object_info.node:
		if mode == "resize" and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			var new_scale_x: float = 0.0000000001
			if old_scale.x / (old_mouse_position.x / get_local_mouse_position().x) != 0:
				new_scale_x = old_scale.x / (old_mouse_position.x / get_local_mouse_position().x)
			var new_scale_y: float = 0.0000000001
			if old_scale.y / (old_mouse_position.y / get_local_mouse_position().y) != 0:
				new_scale_y = old_scale.y / (old_mouse_position.y / get_local_mouse_position().y)
			var new_scale: Vector2 = Vector2(1, 1)
			if Input.is_action_pressed("shift"):
				if new_scale_x >= new_scale_y:
					new_scale = Vector2(new_scale_x, new_scale_x)
				else:
					new_scale = Vector2(new_scale_y, new_scale_y)
			else:
				new_scale = Vector2(new_scale_x, new_scale_y)
			object_info.scale = new_scale
			object_info.node.self_modulate.a = 0.75
			grab_focus()
		elif mode == "move" and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			var position_x: float = get_local_mouse_position().rotated(deg_to_rad(object_info.rotation)).x - old_mouse_position.x
			var position_y: float = get_local_mouse_position().rotated(deg_to_rad(object_info.rotation)).y - old_mouse_position.y
			object_info.position = Vector2(old_position.x + position_x, old_position.y + position_y)
			object_info.node.global_position = object_info.position
			object_info.node.self_modulate.a = 0.75
			move_button.global_position = object_info.position
			grab_focus()
		elif mode == "edit" and edit_text.has_focus():
			edit_text.size = Vector2(0, 0)
		else:
			if mode == "move":
				emit_signal("object_moved", object_info)
			elif mode == "resize":
				emit_signal("object_resized", object_info)
			elif mode == "edit":
				if edit_text.text == null or edit_text.text == "":
					delete_object()
				else:
					_change_object_text(edit_text.text)
			mode = "idle"
			edit_text.visible = false
			edit_text_color_rect.visible = false
			edit_text_rect.visible = false
			select_rect.visible = true
			buttons.visible = true
			position = Vector2(object_info.position.x + (object_info.offset.x * object_info.scale.x), object_info.position.y + (object_info.offset.y * object_info.scale.y))
			move_button.position = Vector2.ZERO
			rotation_degrees = object_info.rotation
			if object_info.node:
				object_info.node.visible = true
				object_info.node.self_modulate.a = 1
			if object_info.type == "stamp" or object_info.type == "text":
				move_button.visible = true
			else:
				move_button.visible = false
			if !check_focus():
				close()
		update_display()
		process_buttons()
		visible = true
	else:
		visible = false
		select_rect.visible = false
		buttons.visible = false
		if object_info.node:
			object_info.node.visible = true
		move_button.visible = false
		edit_text.visible = false
		edit_text_color_rect.visible = false
		edit_text_rect.visible = false


func set_object_info(enabled_buttons: Dictionary, new_object_info: Dictionary, new_extra_object_info: Dictionary = {}):
	var new_delete_enabled = false
	var new_resize_enabled = false
	var new_options_enabled = false
	var new_edit_enabled = false
	if enabled_buttons.has("delete") and enabled_buttons.delete == true:
		new_delete_enabled = true
	if enabled_buttons.has("resize") and enabled_buttons.resize == true:
		new_resize_enabled = true
	if enabled_buttons.has("options") and enabled_buttons.options == true:
		new_options_enabled = true
	if enabled_buttons.has("edit") and enabled_buttons.edit == true:
		new_edit_enabled = true
	enabled_list = [new_delete_enabled, new_resize_enabled, new_options_enabled, new_edit_enabled]
	object_info = {"type": "", "node": null, "position": Vector2(0, 0), "rotation": 0, "offset": Vector2(0, 0),
	"size": Vector2(0, 0), "scale": Vector2(0, 0), "text": null, "info": null}
	if new_object_info.has("type"):
		object_info.type = new_object_info.type
	if new_object_info.has("node"):
		object_info.node = new_object_info.node
	if new_object_info.has("position"):
		object_info.position = new_object_info.position
	if new_object_info.has("rotation"):
		object_info.rotation = new_object_info.rotation
	if new_object_info.has("offset"):
		object_info.offset = new_object_info.offset
	if new_object_info.has("size"):
		object_info.size = new_object_info.size
	if new_object_info.has("scale"):
		object_info.scale = new_object_info.scale
	if new_object_info.has("info"):
		object_info.info = new_object_info.info
	if !new_extra_object_info.is_empty():
		extra_object_info = new_extra_object_info
	grab_focus()


func update_display():
	var camera_zoom = Vector2(1.0, 1.0)
	var camera_scale = 1.0
	var camera = get_viewport().get_camera_2d()
	if camera:
		camera_zoom = camera.zoom
		if "camera_zoom" in camera:
			camera_scale = camera.camera_zoom
	if object_info.node != null:
		var display_size = Vector2(1, 1)
		var display_scale = Vector2(1, 1)
		if object_info.type == "text" and object_info.has("info") and object_info.info.has("text"):
			display_size = Vector2(object_info.node.size.x * abs(object_info.node.scale.x), object_info.node.size.y * abs(object_info.node.scale.y))
			display_scale = Vector2(abs(object_info.node.scale.x) / object_info.node.scale.x, abs(object_info.node.scale.y) / object_info.node.scale.y)
		else:
			display_size = Vector2(object_info.size.x * abs(object_info.scale.x), object_info.size.y * abs(object_info.scale.y))
			display_scale = Vector2(abs(object_info.scale.x) / object_info.scale.x, abs(object_info.scale.y) / object_info.scale.y)
		object_info.node.scale = object_info.scale
		select_rect.size = display_size
		select_rect.scale = display_scale
		select_rect.border_width = 3.0 / camera_scale
		move_button.size = display_size
		move_button.scale = display_scale
		edit_text.size = object_info.size
		edit_text.scale = object_info.scale
		edit_text_color_rect.size = Vector2(edit_text.size.x * abs(edit_text.scale.x), edit_text.size.y * abs(edit_text.scale.y))
		edit_text_color_rect.scale = Vector2(abs(edit_text.scale.x) / edit_text.scale.x, abs(edit_text.scale.y) / edit_text.scale.y)
		edit_text_rect.size = Vector2(edit_text.size.x * abs(edit_text.scale.x), edit_text.size.y * abs(edit_text.scale.y))
		edit_text_rect.scale = Vector2(abs(edit_text.scale.x) / edit_text.scale.x, abs(edit_text.scale.y) / edit_text.scale.y)
		if mode == "edit" and object_info.type == "text" and object_info.has("info") and object_info.info.has("text"):
			display_size = Vector2(edit_text.size.x * abs(edit_text.scale.x), edit_text.size.y * abs(edit_text.scale.y))
			display_scale = Vector2(abs(edit_text.scale.x) / edit_text.scale.x, abs(edit_text.scale.y) / edit_text.scale.y)
		position_buttons(display_size, display_scale, camera_zoom)


func position_buttons(rect_size: Vector2, rect_scale: Vector2, camera_zoom: Vector2 = Vector2(1.0, 1.0)) -> void:
	var button_counter: int = 0
	for button in buttons.get_child_count():
		if !(buttons.get_child(button).name == "EditButton" and mode == "edit") and enabled_list.get(button) != null and enabled_list[button] == true:
			buttons.get_child(button).position = Vector2((rect_size.x * (abs(rect_scale.x) / rect_scale.x)) * position_list[button_counter].x - buttons.get_child(button).size.x / 2, (rect_size.y * (abs(rect_scale.y) / rect_scale.y)) * position_list[button_counter].y - buttons.get_child(button).size.y / 2)
			buttons.get_child(button).scale = Vector2(1.0, 1.0) / camera_zoom
			buttons.get_child(button).visible = true
			button_counter += 1
		else:
			buttons.get_child(button).visible = false


func process_buttons() -> void:
	for button_node in buttons.get_child_count():
		for button in buttons.get_child(button_node).get_children():
			if button is Button:
				var control_node: Control
				if button.is_hovered() and !button.button_pressed:
					if buttons.get_child(button_node).has_node("SmallColorRect"):
						control_node = buttons.get_child(button_node).get_node("SmallColorRect")
						control_node.scale = Vector2(1.5, 1.5)
					if buttons.get_child(button_node).has_node("LargeColorRect"):
						control_node = buttons.get_child(button_node).get_node("LargeColorRect")
						control_node.color = button_colors[button_node]
						control_node.scale = Vector2(1.5, 1.5)
					if buttons.get_child(button_node).has_node("SmallTexture"):
						control_node = buttons.get_child(button_node).get_node("SmallTexture")
						control_node.visible = false
					if buttons.get_child(button_node).has_node("LargeTexture"):
						control_node = buttons.get_child(button_node).get_node("LargeTexture")
						control_node.self_modulate = Color("000000")
						control_node.visible = true
					button.scale = Vector2(1.5, 1.5)
				else:
					if buttons.get_child(button_node).has_node("SmallColorRect"):
						control_node = buttons.get_child(button_node).get_node("SmallColorRect")
						control_node.scale = Vector2(1, 1)
					if buttons.get_child(button_node).has_node("LargeColorRect"):
						control_node = buttons.get_child(button_node).get_node("LargeColorRect")
						control_node.color = Color("7f7f7f")
						control_node.scale = Vector2(1, 1)
					if buttons.get_child(button_node).has_node("SmallTexture"):
						control_node = buttons.get_child(button_node).get_node("SmallTexture")
						control_node.self_modulate = button_colors[button_node]
						control_node.visible = true
					if buttons.get_child(button_node).has_node("LargeTexture"):
						control_node = buttons.get_child(button_node).get_node("LargeTexture")
						control_node.visible = false
					button.scale = Vector2(1, 1)


func move_object() -> void:
	if (object_info.type == "stamp" or object_info.type == "text") and mode != "move" and object_info.node:
		old_position = object_info.position
		old_mouse_position = get_local_mouse_position().rotated(deg_to_rad(object_info.rotation))
		select_rect.visible = false
		buttons.visible = false
		mode = "move"


func delete_object():
	emit_signal("object_deleted", object_info)
	object_info = {"type": "", "node": null, "position": Vector2(0, 0), "rotation": 0, "offset": Vector2(0, 0),
	"size": Vector2(0, 0), "scale": Vector2(0, 0), "text": null, "info": null}
	extra_object_info = {}
	mode = "idle"


func resize_object() -> void:
	if (object_info.type == "stamp" or object_info.type == "text") and mode != "resize" and object_info.node:
		old_scale = object_info.scale
		old_mouse_position = Vector2($Buttons/ResizeButton.position.x + ($Buttons/ResizeButton.size.x / 2), $Buttons/ResizeButton.position.y + ($Buttons/ResizeButton.size.y / 2))
		select_rect.visible = false
		buttons.visible = false
		move_button.visible = false
		mode = "resize"


func show_object_options():
	pass


func edit_object():
	if object_info.node != null and object_info.type == "text" and object_info.has("info") and object_info.info.has("text"):
		select_rect.visible = false
		object_info.node.visible = false
		move_button.visible = false
		edit_text_color_rect.visible = true
		edit_text_rect.visible = true
		edit_text.visible = true
		edit_text.grab_focus()
		mode = "edit"


func _change_object_text(new_text: String):
	if object_info.node != null and object_info.type == "text" and object_info.has("info") and object_info.info.has("text"):
		object_info.info.text = new_text
		object_info.node.text = object_info.info.text
		emit_signal("object_edited", object_info)


func close():
	object_info = {"type": "", "node": null, "position": Vector2(0, 0), "rotation": 0, "offset": Vector2(0, 0),
	"size": Vector2(0, 0), "scale": Vector2(0, 0), "text": null, "info": null}
	extra_object_info = {}
	mode = "idle"


func check_focus() -> bool:
	if has_focus() or move_button.has_focus() or edit_text.has_focus():
		return true
	for button in buttons.get_children():
		if button.has_focus():
			return true
		if button.get_child_count() > 0:
			for button_child in buttons.get_children():
				if button_child.has_focus():
					return true
	return false
