extends BlockSetting

signal change_settings_changed

@onready var blockpicker_popup = preload("res://pages/editor/setting_popups/block_picker/block_picker_popup.gd")
@onready var change_tick_box = $ChangeTickBox
@onready var change_pattern_holder = $ChangePatternHolder
@onready var show_block_picker_button = $ShowBlockPickerButton

var change_tick: float = ConfigurableBlockSettings.default_block_properties.change_tick
var change_pattern: Array = ConfigurableBlockSettings.default_block_properties.change_pattern


func _ready() -> void:
	change_tick_box.init("float", str(change_tick), 0.0, 99999999.9)
	change_tick_box.return_line.connect(_update_change_tick)
	change_pattern_holder.block_list_changed.connect(_update_change_pattern)
	change_pattern_holder.set_block_pattern_size(Vector2(372.0, 180.0))
	change_pattern_holder.init(change_pattern)
	show_block_picker_button.pressed.connect(_show_block_picker)
	connect_node(self, "change_settings_changed")


func send_signal():
	emit_signal("change_settings_changed", {"change_tick": change_tick, "change_pattern": change_pattern})


func _show_block_picker():
	PopupManager.add_custom_popup(blockpicker_popup, {"blockpicker_clicked_func": Callable(change_pattern_holder, "_drag_block"), "close_after_select": false, "popup_global_position": Vector2(show_block_picker_button.global_position.x + show_block_picker_button.size.x + 20, show_block_picker_button.global_position.y), "send_block_picker_size_and_position_func": Callable(change_pattern_holder, "set_block_picker_rect")}, self)


func _update_change_tick(new_change_tick: float) -> void:
	change_tick = new_change_tick
	send_signal()


func _update_change_pattern(new_change_pattern: Array) -> void:
	change_pattern = new_change_pattern
	send_signal()


func set_settings(new_settings: Dictionary):
	if new_settings.has("change_tick"):
		change_tick = new_settings.change_tick
		change_tick_box._update_text(str(change_tick))
	if new_settings.has("change_pattern"):
		change_pattern = new_settings.change_pattern
		change_pattern_holder.init(change_pattern)
