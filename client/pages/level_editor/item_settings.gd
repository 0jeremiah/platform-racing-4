extends Control

var item_list = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]


func _ready() -> void:
	for child in get_children():
		if child is CheckBox:
			child.pressed.connect(_update_item_list)
	_update_item_list()


func _on_control_event(event: Dictionary) -> void:
	if event.type == EditorEvents.SET_ITEMS:
		_set_item_list(event.items)


func _set_item_list(new_item_list: Array = []):
	item_list = new_item_list
	for child in get_child_count():
		if get_child(child) is CheckBox:
			if item_list.has(child):
				get_child(child).set_pressed_no_signal(true)
			else:
				get_child(child).set_pressed_no_signal(false)
	_update_item_list()


func _update_item_list() -> void:
	item_list = []
	for child in get_child_count():
		if get_child(child) is CheckBox and get_child(child).button_pressed:
			item_list.push_back(child)
