extends BlockSetting

signal item_settings_changed

@onready var infinite_check_box = $InfiniteCheckBox
@onready var item_supply_box = $ItemSupplyBox

var infinite: bool = false
var item_supply: int = 1


func _ready() -> void:
	infinite_check_box.pressed.connect(_toggle_infinite)
	item_supply_box.init("int", "1", 0, 9999999)
	item_supply_box.return_line.connect(_change_item_supply)


func _toggle_infinite():
	infinite = infinite_check_box.button_pressed
	emit_signal("item_settings_changed", {"infinite": infinite, "item_supply": item_supply})


func _change_item_supply(new_item_supply: int):
	item_supply = new_item_supply
	emit_signal("item_settings_changed", {"infinite": infinite, "item_supply": item_supply})


func set_settings(new_settings: Dictionary):
	if new_settings.has("infinite"):
		infinite = new_settings.infinite
	if new_settings.has("item_supply"):
		item_supply = clamp(new_settings.item_supply, 0, 9999999)
		item_supply_box._update_text(str(item_supply))
