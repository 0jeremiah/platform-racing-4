extends SideOption

signal heart_options_changed

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
	connect_node(self, "heart_options_changed")


func _toggle_exact():
	exact = exact_check_box.button_pressed
	emit_signal("heart_options_changed", {"hp": hp, "exact": exact, "invincibility": invincibility})


func _toggle_invincibility():
	invincibility = invincibility_check_box.button_pressed
	emit_signal("heart_options_changed", {"hp": hp, "exact": exact, "invincibility": invincibility})


func _change_hp(new_hp: float):
	hp = new_hp
	emit_signal("heart_options_changed", {"hp": hp, "exact": exact, "invincibility": invincibility})


func set_options(new_options: Dictionary):
	if new_options.has("hp"):
		hp = clamp(new_options.hp, -9999999.9, 99999999.9)
		heart_box._update_text(str(hp))
	if new_options.has("exact"):
		exact = new_options.exact
	if new_options.has("invincibility"):
		invincibility = new_options.invincibility
	options = {"hp": hp, "exact": exact, "invincibility": invincibility}
