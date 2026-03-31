extends SideOption

signal item_options_changed

@onready var item_supply_box = $ItemSupplyBox
@onready var infinite_check_box = $InfiniteCheckBox

var item_supply: int = 1
var infinite: bool = false
var item_list: Array = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]


func _ready() -> void:
	item_supply_box.init("int", "1", 0, 9999999)
	item_supply_box.return_line.connect(_change_item_supply)
	infinite_check_box.pressed.connect(_toggle_infinite)
	for child in get_child_count():
		if get_child(child) is CheckBox:
			get_child(child).pressed.connect(maybe_add_item.bind(child))
	update_item_list()
	connect_node(self, "item_options_changed")


func _toggle_infinite():
	infinite = infinite_check_box.button_pressed
	emit_signal("item_options_changed", {"item_supply": item_supply, "infinite": infinite, "item_list": item_list})


func _change_item_supply(new_item_supply: int):
	item_supply = new_item_supply
	emit_signal("item_options_changed", {"item_supply": item_supply, "infinite": infinite, "item_list": item_list})


func maybe_add_item(child_id: int):
	var item_id = child_id + 1
	if get_child(child_id).button_pressed:
		if !item_list.has(item_id):
			item_list.append(item_id)
	else:
		while item_list.has(item_id):
			item_list.erase(item_id)
	item_list.sort()
	emit_signal("item_options_changed", {"item_supply": item_supply, "infinite": infinite, "item_list": item_list})


func update_item_list() -> void:
	for child in get_child_count():
		if get_child(child) is CheckBox:
			if item_list.has(child + 1):
				get_child(child).set_pressed_no_signal(true)
			else:
				get_child(child).set_pressed_no_signal(false)


func set_options(new_options: Dictionary):
	if new_options.has("item_supply"):
		item_supply = clamp(new_options.item_supply, 0, 9999999)
		item_supply_box._update_text(str(item_supply))
	if new_options.has("infinite"):
		infinite = new_options.infinite
	if new_options.has("item_list"):
		item_list = new_options.item_list
	options = {"item_supply": item_supply, "infinite": infinite, "item_list": item_list}
