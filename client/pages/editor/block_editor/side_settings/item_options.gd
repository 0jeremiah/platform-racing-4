extends Control

signal item_list_updated

var item_list = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]


func _ready() -> void:
	for child in get_child_count():
		if get_child(child) is CheckBox:
			get_child(child).pressed.connect(maybe_add_item.bind(child))
	update_item_list()


func set_item_list(new_item_list: Array = []):
	item_list = new_item_list
	update_item_list()


func maybe_add_item(child_id: int):
	var item_id = child_id + 1
	if get_child(child_id).button_pressed:
		if !item_list.has(item_id):
			item_list.append(item_id)
	else:
		while item_list.has(item_id):
			item_list.erase(item_id)
	item_list.sort()
	emit_signal("item_list_updated", item_list)


func update_item_list() -> void:
	for child in get_child_count():
		if get_child(child) is CheckBox:
			if item_list.has(child + 1):
				get_child(child).set_pressed_no_signal(true)
			else:
				get_child(child).set_pressed_no_signal(false)
