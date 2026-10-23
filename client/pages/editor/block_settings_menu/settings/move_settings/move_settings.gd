extends BlockSetting

signal move_settings_changed

@onready var tick_box = $TickBox
@onready var pattern_box = $PatternBox
@onready var random_button = $RandomButton
@onready var loop_button = $LoopButton
@onready var parse_results_label = $ParseResultsLabel

var allowed_commands: Array = ["up", "down", "left", "right", "wait", "random", "return"]
var move_tick: float = ConfigurableBlockSettings.default_block_properties.move_tick
var old_move_pattern: String = ConfigurableBlockSettings.default_block_properties.move_pattern
var move_pattern: String = ConfigurableBlockSettings.default_block_properties.move_pattern
var randomize_move_pattern: bool = ConfigurableBlockSettings.default_block_properties.randomize_move_pattern
var loop_move_pattern: bool = ConfigurableBlockSettings.default_block_properties.loop_move_pattern


func _ready() -> void:
	tick_box.init("float", str(move_tick), 0.0, 99999999.9)
	tick_box.return_line.connect(_update_tick)
	pattern_box.text_changed.connect(_parse_pattern)
	random_button.pressed.connect(_toggle_random)
	loop_button.pressed.connect(_toggle_loop)
	_parse_pattern()
	connect_node(self, "move_settings_changed")


func send_signal():
	emit_signal("move_settings_changed", {"move_tick": move_tick, "move_pattern": move_pattern,
	"randomize_move_pattern": randomize_move_pattern, "loop_move_pattern": loop_move_pattern})


func _update_tick(new_move_tick: float):
	move_tick = new_move_tick
	send_signal()


func _toggle_random():
	randomize_move_pattern = random_button.button_pressed
	send_signal()


func _toggle_loop():
	loop_move_pattern = loop_button.button_pressed
	send_signal()


func _parse_pattern():
	var move_pattern_info = ConfigurableBlockSettings.parse_move_pattern(pattern_box.text)
	move_pattern = old_move_pattern
	parse_results_label.set("theme_override_colors/default_color", Color("7F0000"))
	parse_results_label.text = move_pattern_info.message
	if move_pattern_info.success:
		move_pattern = move_pattern_info.move_pattern
		parse_results_label.set("theme_override_colors/default_color", Color("007f00"))
		send_signal()


func set_settings(new_settings: Dictionary):
	if new_settings.has("move_tick"):
		move_tick = new_settings.move_tick
	if new_settings.has("move_pattern"):
		pattern_box.text = new_settings.move_pattern
		_parse_pattern()
	if new_settings.has("randomize_move_pattern"):
		randomize_move_pattern = new_settings.randomize_move_pattern
	if new_settings.has("loop_move_pattern"):
		loop_move_pattern = new_settings.loop_move_pattern
