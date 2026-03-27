extends Control

signal size_options_changed

@onready var multiplier_box = $MultiplierBox
@onready var exact_check_box = $ExactCheckBox

var exact: bool = false
var multiplier: float = 2.0


func _ready() -> void:
	multiplier_box.init("float", "2.0", 0.1, 10.0)
	multiplier_box.return_line.connect(_change_multiplier)
	exact_check_box.pressed.connect(_toggle_exact)


func _toggle_exact():
	exact = exact_check_box.button_pressed
	emit_signal("size_options_changed", {"exact": exact, "multiplier": multiplier})


func set_exact(new_exact: bool):
	exact = new_exact


func _change_multiplier(new_multiplier: float):
	multiplier = new_multiplier
	emit_signal("size_options_changed", {"exact": exact, "multiplier": multiplier})


func set_multiplier(new_multiplier: float):
	multiplier_box._update_text(str(new_multiplier))
	multiplier = clamp(new_multiplier, 0.00000001, 99999999.9)
