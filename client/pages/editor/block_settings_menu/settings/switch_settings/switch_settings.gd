extends BlockSetting

signal switch_settings_changed

@onready var blockpicker_popup = preload("res://pages/editor/setting_popups/block_picker/block_picker_popup.gd")
@onready var activate_offset_x_box = $ActivateOffsetXBox
@onready var activate_offset_y_box = $ActivateOffsetYBox
@onready var limit_activate_range_check_box = $LimitActivateRangeCheckBox
@onready var activate_range_x_box = $ActivateRangeXBox
@onready var activate_range_y_box = $ActivateRangeYBox

var activate_offset: Vector2i = Vector2i(ConfigurableBlockSettings.default_block_properties.activate_offset.x, ConfigurableBlockSettings.default_block_properties.activate_offset.y)
var limit_activate_range: bool = ConfigurableBlockSettings.default_block_properties.limit_activate_range
var activate_range: Vector2i = Vector2i(ConfigurableBlockSettings.default_block_properties.activate_range.x, ConfigurableBlockSettings.default_block_properties.activate_range.y)


func _ready() -> void:
	activate_offset_x_box.init("int", str(activate_offset.x), -999999999, 9999999999)
	activate_offset_x_box.return_line.connect(_update_activate_offset_x)
	activate_offset_y_box.init("int", str(activate_offset.y), -999999999, 9999999999)
	activate_offset_y_box.return_line.connect(_update_activate_offset_y)
	limit_activate_range_check_box.pressed.connect(_toggle_limit_activate_range)
	activate_range_x_box.init("int", str(activate_range.x), 0, 9999999999)
	activate_range_x_box.return_line.connect(_update_activate_range_x)
	activate_range_y_box.init("int", str(activate_range.y), 0, 9999999999)
	activate_range_y_box.return_line.connect(_update_activate_range_y)
	connect_node(self, "switch_settings_changed")


func send_signal():
	emit_signal("switch_settings_changed", {"activate_offset": {"x": activate_offset.x, "y": activate_offset.y}, "limit_activate_range": limit_activate_range, "activate_range": {"x": activate_range.x, "y": activate_range.y}})


func _update_activate_offset_x(new_activate_offset_x: int):
	activate_offset = Vector2i(new_activate_offset_x, activate_offset.y)
	send_signal()


func _update_activate_offset_y(new_activate_offset_y: int):
	activate_offset = Vector2i(activate_offset.x, new_activate_offset_y)
	send_signal()


func _toggle_limit_activate_range():
	limit_activate_range = limit_activate_range_check_box.button_pressed
	send_signal()


func _update_activate_range_x(new_activate_range_x: int):
	activate_range = Vector2i(new_activate_range_x, activate_range.y)
	send_signal()


func _update_activate_range_y(new_activate_range_y: int):
	activate_range = Vector2i(activate_range.x, new_activate_range_y)
	send_signal()


func set_settings(new_settings: Dictionary):
	if new_settings.has("activate_offset"):
		activate_offset = Vector2(clamp(new_settings.activate_offset.x, -999999999, 9999999999), clamp(new_settings.activate_offset.y, -999999999, 9999999999))
		activate_offset_x_box._update_text(str(activate_offset.x))
		activate_offset_y_box._update_text(str(activate_offset.y))
	if new_settings.has("limit_activate_range"):
		limit_activate_range = new_settings.limit_activate_range
		limit_activate_range_check_box.set_pressed_no_signal(limit_activate_range)
	if new_settings.has("activate_range"):
		activate_range = Vector2(clamp(new_settings.activate_range.x, 0, 9999999999), clamp(new_settings.activate_range.y, 0, 9999999999))
		activate_range_x_box._update_text(str(activate_range.x))
		activate_range_y_box._update_text(str(activate_range.y))
