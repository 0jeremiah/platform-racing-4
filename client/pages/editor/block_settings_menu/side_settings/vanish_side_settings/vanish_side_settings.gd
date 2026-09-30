extends BlockSideSetting

signal vanish_side_settings_changed

@onready var fade_duration_box = $FadeDurationBox
@onready var fade_cooldown_box = $FadeCooldownBox
@onready var revert_check_box = $RevertCheckBox

var fade_duration: float = 0.3
var fade_cooldown: float = 2.0
var revert: bool = true


func _ready() -> void:
	fade_duration_box.init("float", "0.3", 0.0, 99999999.9)
	fade_duration_box.return_line.connect(_change_fade_duration)
	fade_cooldown_box.init("float", "2.0", 0.0, 99999999.9)
	fade_cooldown_box.return_line.connect(_change_fade_cooldown)
	revert_check_box.pressed.connect(_toggle_revert)
	connect_node(self, "vanish_side_settings_changed")


func _change_fade_duration(new_fade_duration: float):
	fade_duration = new_fade_duration
	emit_signal("vanish_side_settings_changed", {"fade_duration": fade_duration, "fade_cooldown": fade_cooldown, "revert": revert})


func _change_fade_cooldown(new_fade_cooldown: float):
	fade_cooldown = new_fade_cooldown
	emit_signal("vanish_side_settings_changed", {"fade_duration": fade_duration, "fade_cooldown": fade_cooldown, "revert": revert})


func _toggle_revert():
	revert = revert_check_box.button_pressed
	emit_signal("vanish_side_settings_changed", {"fade_duration": fade_duration, "fade_cooldown": fade_cooldown, "revert": revert})


func set_side_settings(new_side_settings: Dictionary):
	if new_side_settings.has("fade_duration"):
		fade_duration = clamp(new_side_settings.fade_duration, 0.0, 99999999.9)
		fade_duration_box._update_text(str(fade_duration))
	if new_side_settings.has("fade_cooldown"):
		fade_cooldown = clamp(new_side_settings.fade_cooldown, 0.0, 99999999.9)
		fade_cooldown_box._update_text(str(fade_cooldown))
	if new_side_settings.has("revert"):
		revert = new_side_settings.revert
	side_settings = {"fade_duration": fade_duration, "fade_cooldown": fade_cooldown, "revert": revert}
