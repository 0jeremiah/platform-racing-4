extends BlockSetting

signal presence_switch_settings_changed

@onready var blockpicker_popup = preload("res://pages/editor/setting_popups/block_picker/block_picker_popup.gd")
@onready var tab_bar = $TabBar
@onready var limit_activate_range_check_box = $LimitActivateRangeCheckBox
@onready var activate_range_x_box = $ActivateRangeXBox
@onready var activate_range_y_box = $ActivateRangeYBox
@onready var activatable_settings_container = $ActivatableSettingsContainer
@onready var activatable_settings = $ActivatableSettingsContainer/ActivatableSettings
@onready var activatable_blocks_container = $ActivatableBlocksContainer
@onready var activatable_block_list_holder = $ActivatableBlocksContainer/ActivatableBlockListHolder
@onready var show_block_picker_button = $ActivatableBlocksContainer/ShowBlockPickerButton

var limit_activate_range: bool = ConfigurableBlockSettings.default_block_properties.limit_activate_range
var activate_range: Vector2i = Vector2i(ConfigurableBlockSettings.default_block_properties.activate_range.x, ConfigurableBlockSettings.default_block_properties.activate_range.y)
var activate_list: Dictionary = {"settings": ["gear"], "side_settings": [], "blocks": []}


func _ready() -> void:
	BlockManager.load_default_block_configs()
	tab_bar.tab_changed.connect(_update_display)
	limit_activate_range_check_box.pressed.connect(_toggle_limit_activate_range)
	activate_range_x_box.init("int", str(activate_range.x), 1, 9999999999)
	activate_range_x_box.return_line.connect(_update_activate_range_x)
	activate_range_y_box.init("int", str(activate_range.y), 1, 9999999999)
	activate_range_y_box.return_line.connect(_update_activate_range_y)
	activatable_settings.activatable_settings_changed.connect(_update_activate_list_settings_and_side_settings)
	activatable_settings.init({"settings": activate_list.settings, "side_settings": activate_list.side_settings})
	activatable_block_list_holder.block_list_changed.connect(_update_activate_list_blocks)
	activatable_block_list_holder.set_block_pattern_size(Vector2(380.0, 120.0))
	activatable_block_list_holder.set_max_blocks(12)
	activatable_block_list_holder.set_allow_duplicate_blocks(false)
	activatable_block_list_holder.init(activate_list.blocks)
	show_block_picker_button.pressed.connect(_show_block_picker)
	connect_node(self, "presence_switch_settings_changed")
	_update_display(tab_bar.current_tab)


func _update_display(new_index: int):
	activatable_settings_container.visible = false
	activatable_blocks_container.visible = false
	if new_index == 1:
		activatable_blocks_container.visible = true
	else:
		activatable_settings_container.visible = true


func _show_block_picker():
	PopupManager.add_custom_popup(blockpicker_popup, {"blockpicker_clicked_func": Callable(activatable_block_list_holder, "_drag_block"), "close_after_select": false, "popup_global_position": Vector2(show_block_picker_button.global_position.x + show_block_picker_button.size.x + 20, show_block_picker_button.global_position.y), "send_block_picker_size_and_position_func": Callable(activatable_block_list_holder, "set_block_picker_rect")}, self)


func _toggle_limit_activate_range():
	limit_activate_range = limit_activate_range_check_box.button_pressed
	emit_signal("presence_switch_settings_changed", {"limit_activate_range": limit_activate_range, "activate_range": {"x": activate_range.x, "y": activate_range.y}, "activate_list": activate_list})


func _update_activate_range_x(new_activate_range_x: int):
	activate_range = Vector2i(new_activate_range_x, activate_range.y)
	emit_signal("presence_switch_settings_changed", {"limit_activate_range": limit_activate_range, "activate_range": {"x": activate_range.x, "y": activate_range.y}, "activate_list": activate_list})


func _update_activate_range_y(new_activate_range_y: int):
	activate_range = Vector2i(activate_range.x, new_activate_range_y)
	emit_signal("presence_switch_settings_changed", {"limit_activate_range": limit_activate_range, "activate_range": {"x": activate_range.x, "y": activate_range.y}, "activate_list": activate_list})


func _update_activate_list_settings_and_side_settings(new_settings_and_side_settings: Dictionary) -> void:
	activate_list.settings = new_settings_and_side_settings.settings
	activate_list.side_settings = new_settings_and_side_settings.side_settings
	emit_signal("presence_switch_settings_changed", {"limit_activate_range": limit_activate_range, "activate_range": {"x": activate_range.x, "y": activate_range.y}, "activate_list": activate_list})


func _update_activate_list_blocks(new_blocks: Array) -> void:
	activate_list.blocks = new_blocks
	emit_signal("presence_switch_settings_changed", {"limit_activate_range": limit_activate_range, "activate_range": {"x": activate_range.x, "y": activate_range.y}, "activate_list": activate_list})


func set_settings(new_settings: Dictionary):
	if new_settings.has("limit_activate_range"):
		limit_activate_range = new_settings.limit_activate_range
		limit_activate_range_check_box.set_pressed_no_signal(limit_activate_range)
	if new_settings.has("activate_range"):
		activate_range = Vector2(clamp(new_settings.activate_range.x, 1, 9999999999), clamp(new_settings.activate_range.y, 1, 9999999999))
		activate_range_x_box._update_text(str(activate_range.x))
		activate_range_y_box._update_text(str(activate_range.y))
	if new_settings.has("activate_list"):
		activate_list = new_settings.activate_list
		activatable_settings.init({"settings": activate_list.settings, "side_settings": activate_list.side_settings})
		activatable_block_list_holder.init(activate_list.blocks)
