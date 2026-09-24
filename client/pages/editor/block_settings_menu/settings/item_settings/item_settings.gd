extends BlockSetting

signal item_settings_changed

@onready var infinite_items_check_box = $InfiniteItemsCheckBox
@onready var item_supply_box = $ItemSupplyBox

var infinite_items: bool = ConfigurableBlockSettings.default_block_properties.infinite_items
var item_supply: int = ConfigurableBlockSettings.default_block_properties.item_supply


func _ready() -> void:
	infinite_items_check_box.pressed.connect(_toggle_infinite_items)
	item_supply_box.init("int", str(item_supply), 0, 9999999)
	item_supply_box.return_line.connect(_change_item_supply)
	connect_node(self, "item_settings_changed")


func _toggle_infinite_items():
	infinite_items = infinite_items_check_box.button_pressed
	emit_signal("item_settings_changed", {"infinite_items": infinite_items, "item_supply": item_supply})


func _change_item_supply(new_item_supply: int):
	item_supply = new_item_supply
	emit_signal("item_settings_changed", {"infinite_items": infinite_items, "item_supply": item_supply})


func set_settings(new_settings: Dictionary):
	if new_settings.has("infinite_items"):
		infinite_items = new_settings.infinite_items
		infinite_items_check_box.set_pressed_no_signal(infinite_items)
	if new_settings.has("item_supply"):
		item_supply = clamp(new_settings.item_supply, 0, 9999999)
		item_supply_box._update_text(str(item_supply))
