extends SideOption

signal vanish_options_changed

@onready var animation_duration_box = $AnimationDurationBox
@onready var cooldown_box = $CooldownBox

var animation_duration: float = 0.3
var cooldown: float = 2.0


func _ready() -> void:
	animation_duration_box.init("float", "0.3", 0.0, 99999999.9)
	animation_duration_box.return_line.connect(_change_animation_duration)
	cooldown_box.init("float", "2.0", 0.0, 99999999.9)
	cooldown_box.return_line.connect(_change_cooldown)
	connect_node(self, "vanish_options_changed")


func _change_animation_duration(new_animation_duration: float):
	animation_duration = new_animation_duration
	emit_signal("vanish_options_changed", {"animation_duration": animation_duration, "cooldown": cooldown})


func _change_cooldown(new_cooldown: float):
	cooldown = new_cooldown
	emit_signal("vanish_options_changed", {"animation_duration": animation_duration, "cooldown": cooldown})


func set_options(new_options: Dictionary):
	if new_options.has("animation_duration"):
		animation_duration = clamp(new_options.animation_duration, 0.0, 99999999.9)
		animation_duration_box._update_text(str(animation_duration))
	if new_options.has("cooldown"):
		cooldown = clamp(new_options.cooldown, 0.0, 99999999.9)
		cooldown_box._update_text(str(cooldown))
	options = {"animation_duration": animation_duration, "cooldown": cooldown}
