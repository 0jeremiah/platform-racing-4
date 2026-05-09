extends BlockSideSetting

signal hurt_side_settings_changed

@onready var push_strength_box = $PushStrengthBox
@onready var hitstun_duration_box = $HitstunDurationBox

var push_strength: float = 1000.0
var hitstun_duration: float = 2.5


func _ready() -> void:
	push_strength_box.init("float", "1000.0", -9999999.9, 99999999.9)
	push_strength_box.return_line.connect(_change_push_strength)
	hitstun_duration_box.init("float", "2.5", 0.0, 99999999.9)
	hitstun_duration_box.return_line.connect(_change_hitstun_duration)
	connect_node(self, "hurt_side_settings_changed")


func _change_push_strength(new_push_strength: float):
	push_strength = new_push_strength
	emit_signal("hurt_side_settings_changed", {"push_strength": push_strength, "hitstun_duration": hitstun_duration})


func _change_hitstun_duration(new_hitstun_duration: float):
	hitstun_duration = new_hitstun_duration
	emit_signal("hurt_side_settings_changed", {"push_strength": push_strength, "hitstun_duration": hitstun_duration})


func set_side_settings(new_side_settings: Dictionary):
	if new_side_settings.has("push_strength"):
		push_strength = clamp(new_side_settings.push_strength, -9999999.9, 99999999.9)
		push_strength_box._update_text(str(push_strength))
	if new_side_settings.has("hitstun_duration"):
		hitstun_duration = clamp(new_side_settings.hitstun_duration, 0.0, 99999999.9)
		hitstun_duration_box._update_text(str(hitstun_duration))
	side_settings = {"push_strength": push_strength, "hitstun_duration": hitstun_duration}
