extends BlockSideSetting

signal heart_side_settings_changed

@onready var heart_box = $HeartBox
@onready var exact_check_box = $ExactCheckBox
@onready var invincibility_check_box = $InvincibilityCheckBox

var hp: float = 1.0
var exact: bool = false
var invincibility: bool = false


func _ready() -> void:
	heart_box.init("float", "1.0", -9999999.9, 99999999.9)
	heart_box.return_line.connect(_change_hp)
	exact_check_box.pressed.connect(_toggle_exact)
	invincibility_check_box.pressed.connect(_toggle_invincibility)
	connect_node(self, "heart_side_settings_changed")


func _toggle_exact():
	exact = exact_check_box.button_pressed
	emit_signal("heart_side_settings_changed", {"hp": hp, "exact": exact, "invincibility": invincibility})


func _toggle_invincibility():
	invincibility = invincibility_check_box.button_pressed
	emit_signal("heart_side_settings_changed", {"hp": hp, "exact": exact, "invincibility": invincibility})


func _change_hp(new_hp: float):
	hp = new_hp
	emit_signal("heart_side_settings_changed", {"hp": hp, "exact": exact, "invincibility": invincibility})


func set_side_settings(new_side_settings: Dictionary):
	if new_side_settings.has("hp"):
		hp = clamp(new_side_settings.hp, -9999999.9, 99999999.9)
		heart_box._update_text(str(hp))
	if new_side_settings.has("exact"):
		exact = new_side_settings.exact
	if new_side_settings.has("invincibility"):
		invincibility = new_side_settings.invincibility
	side_settings = {"hp": hp, "exact": exact, "invincibility": invincibility}
