extends BlockSideSetting

signal item_side_settings_changed

@onready var items_container = $ItemsContainer

var item_buttons: Dictionary = {}
var item_array: Array = []


func _ready() -> void:
	var default_items = Items.items
	for item in default_items:
		var item_check_box = CheckBox.new()
		item_check_box.size = Vector2(180.0, 30.0)
		item_check_box.custom_minimum_size = Vector2(180.0, 30.0)
		item_check_box.clip_text = true
		item_check_box.set("theme_override_font_sizes/font_size", 17)
		item_check_box.text = default_items[item].name
		item_check_box.set_pressed_no_signal(true)
		items_container.add_child(item_check_box)
		item_buttons[item] = {"id": default_items[item].id, "button": item_check_box}
		item_check_box.pressed.connect(maybe_add_item.bind(item))
		item_array.append(default_items[item].id)
	items_container.resized.connect(_change_size)
	connect_node(self, "item_side_settings_changed")


func _change_size() -> void:
	size = items_container.size
	items_container.resized.disconnect(_change_size)


func maybe_add_item(item_name: String) -> void:
	if item_name in item_buttons:
		if item_buttons[item_name].button.button_pressed:
			if !item_array.has(item_buttons[item_name].id):
				item_array.append(item_buttons[item_name].id)
		else:
			while item_array.has(item_buttons[item_name].id):
				item_array.erase(item_buttons[item_name].id)
		item_array.sort()
		emit_signal("item_side_settings_changed", {"item_array": item_array})


func update_item_list() -> void:
	for item in item_buttons:
		if item_array.has(item_buttons[item].id):
			item_buttons[item].button.set_pressed_no_signal(true)
		else:
			item_buttons[item].button.set_pressed_no_signal(false)


func set_side_settings(new_side_settings: Dictionary) -> void:
	if new_side_settings.has("item_array"):
		item_array = new_side_settings.item_array
		update_item_list()
	side_settings = {"item_array": item_array}
