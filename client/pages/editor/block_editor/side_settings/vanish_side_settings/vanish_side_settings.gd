extends BlockSideSetting

signal vanish_side_settings_changed

@onready var fade_duration_box = $FadeDurationBox
@onready var fade_cooldown_box = $FadeCooldownBox

var fade_duration: float = 0.3
var fade_cooldown: float = 2.0


func _ready() -> void:
	fade_duration_box.init("float", "0.3", 0.0, 99999999.9)
	fade_duration_box.return_line.connect(_change_fade_duration)
	fade_cooldown_box.init("float", "2.0", 0.0, 99999999.9)
	fade_cooldown_box.return_line.connect(_change_fade_cooldown)
	connect_node(self, "vanish_side_settings_changed")


func _change_fade_duration(new_fade_duration: float):
	fade_duration = new_fade_duration
	emit_signal("vanish_side_settings_changed", {"fade_duration": fade_duration, "fade_cooldown": fade_cooldown})


func _change_fade_cooldown(new_fade_cooldown: float):
	fade_cooldown = new_fade_cooldown
	emit_signal("vanish_side_settings_changed", {"fade_duration": fade_duration, "fade_cooldown": fade_cooldown})


func set_side_settings(new_side_settings: Dictionary):
	if new_side_settings.has("fade_duration"):
		fade_duration = clamp(new_side_settings.fade_duration, 0.0, 99999999.9)
		fade_duration_box._update_text(str(fade_duration))
	if new_side_settings.has("fade_cooldown"):
		fade_cooldown = clamp(new_side_settings.fade_cooldown, 0.0, 99999999.9)
		fade_cooldown_box._update_text(str(fade_cooldown))
	side_settings = {"fade_duration": fade_duration, "fade_cooldown": fade_cooldown}
