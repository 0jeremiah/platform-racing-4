extends Control

signal move_settings_changed

@onready var tick_box = $TickBox
@onready var pattern_box = $PatternBox
@onready var random_button = $RandomButton
@onready var loop_button = $LoopButton
@onready var parse_results_label = $ParseResultsLabel

var allowed_commands: Array = ["up", "down", "left", "right", "wait", "random", "return"]
var move_tick: float = 2.5
var old_move_pattern: String = "up, right, down, left"
var move_pattern: String = "up, right, down, left"
var randomize_move_pattern: bool = false
var loop_move_pattern: bool = true


func _ready() -> void:
	tick_box.init("float", "2.5", 0.0, 99999999.9)
	tick_box.return_line.connect(_update_tick)
	pattern_box.text_changed.connect(_parse_pattern)
	random_button.pressed.connect(_toggle_random)
	loop_button.pressed.connect(_toggle_loop)
	_parse_pattern()


func _update_tick(new_move_tick: float):
	move_tick = new_move_tick
	emit_signal("move_settings_changed", {"move_tick": move_tick, "move_pattern": move_pattern,
	"randomize_move_pattern": randomize_move_pattern, "loop_move_pattern": loop_move_pattern})


func _toggle_random():
	randomize_move_pattern = random_button.button_pressed
	emit_signal("move_settings_changed", {"move_tick": move_tick, "move_pattern": move_pattern,
	"randomize_move_pattern": randomize_move_pattern, "loop_move_pattern": loop_move_pattern})


func _toggle_loop():
	loop_move_pattern = loop_button.button_pressed
	emit_signal("move_settings_changed", {"move_tick": move_tick, "move_pattern": move_pattern,
	"randomize_move_pattern": randomize_move_pattern, "loop_move_pattern": loop_move_pattern})


func _parse_pattern():
	move_pattern = ""
	var success: bool = true
	parse_results_label.text = ""
	var pattern_string = pattern_box.text
	if !pattern_string.is_empty():
		var pattern_array = pattern_string.split(",", false, 0)
		for pattern in pattern_array:
			var converted_command = pattern.dedent().remove_chars("0123456789 ").to_lower()
			if converted_command in allowed_commands:
				var command = ""
				match converted_command:
					"up": command = "u"
					"down": command = "d"
					"left": command = "l"
					"right": command = "r"
					"wait": command = "-"
					"return": command = "@"
					"random": command = "*"
					_: command = "*"
				if pattern.remove_chars("0123456789") != pattern:
					var converted_numeration = pattern.dedent().remove_chars("up^downvleft<righ>am ")
					if converted_numeration.is_valid_int():
						var amount = int(converted_numeration)
						for i in range(amount):
							move_pattern = move_pattern + command
					else:
						success = false
						parse_results_label.set("theme_override_colors/default_color", Color("7F0000"))
						parse_results_label.text = "ERROR: One or more invalid numerations."
				else:
					move_pattern = move_pattern + command
			else:
				success = false
				parse_results_label.set("theme_override_colors/default_color", Color("7F0000"))
				parse_results_label.text = "ERROR: One or more invalid commands."
				break
	else:
		success = false
		parse_results_label.set("theme_override_colors/default_color", Color("7F0000"))
		parse_results_label.text = "ERROR: No pattern exists."
	if success:
		parse_results_label.set("theme_override_colors/default_color", Color("007f00"))
		parse_results_label.text = "PASS: All patterns are valid."
		old_move_pattern = move_pattern
		emit_signal("move_settings_changed", {"move_tick": move_tick, "move_pattern": move_pattern,
		"randomize_move_pattern": randomize_move_pattern, "loop_move_pattern": loop_move_pattern})
