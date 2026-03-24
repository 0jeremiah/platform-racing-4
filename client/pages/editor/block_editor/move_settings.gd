extends Control

@onready var tick_box = $TickBox
@onready var pattern_box = $PatternBox
@onready var parse_pattern_button = $ParsePatternButton
@onready var parse_results_label = $ParseResultsLabel

var allowed_commands: Array = ["up", "u", "^", "down", "d", "v", "left", "l", "<", "right", "r", ">", "random", "return"]


func _ready() -> void:
	tick_box.init("float", "2.5", 0.0, 99999999.9)
	parse_pattern_button.pressed.connect(_parse_pattern)
	_parse_pattern()


func _parse_pattern():
	var success: bool = true
	parse_results_label.text = ""
	var pattern_string = pattern_box.text
	if !pattern_string.is_empty():
		var pattern_array = pattern_string.split(",", false, 0)
		for pattern in pattern_array:
			var converted_command = pattern.dedent().remove_chars("0123456789 ").to_lower()
			if converted_command in allowed_commands:
				if pattern.remove_chars("0123456789") != pattern:
					var converted_numeration = pattern.dedent().remove_chars("up^downvleft<righ>am ")
					if converted_numeration.is_valid_int():
						var number = pattern.dedent().remove_chars("up^downvleft<righ>am ")
					else:
						success = false
						parse_results_label.set("theme_override_colors/default_color", Color("7F0000"))
						parse_results_label.text = "ERROR: One or more invalid numerations."
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
