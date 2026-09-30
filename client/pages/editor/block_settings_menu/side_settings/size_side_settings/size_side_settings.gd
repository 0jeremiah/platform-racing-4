extends BlockSideSetting

signal size_side_settings_changed

@onready var multiplier_box = $MultiplierBox
@onready var exact_check_box = $ExactCheckBox

var multiplier: float = 2.0
var exact: bool = false


func _ready() -> void:
	multiplier_box.init("float", "2.0", 0.1, 10.0)
	multiplier_box.return_line.connect(_change_multiplier)
	exact_check_box.pressed.connect(_toggle_exact)
	connect_node(self, "size_side_settings_changed")


func _change_multiplier(new_multiplier: float):
	multiplier = new_multiplier
	emit_signal("size_side_settings_changed", {"exact": exact, "multiplier": multiplier})


func _toggle_exact():
	exact = exact_check_box.button_pressed
	emit_signal("size_side_settings_changed", {"exact": exact, "multiplier": multiplier})


func set_side_settings(new_side_settings: Dictionary):
	if new_side_settings.has("multiplier"):
		multiplier = clamp(new_side_settings.multiplier, 0.00000001, 99999999.9)
		multiplier_box._update_text(str(multiplier))
	if new_side_settings.has("exact"):
		exact = new_side_settings.exact
	side_settings = {"exact": exact, "multiplier": multiplier}
