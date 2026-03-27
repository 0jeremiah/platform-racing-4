extends Control

signal hurt_options_changed

@onready var push_strength_box = $PushStrengthBox
@onready var hitstun_duration_box = $HitstunDurationBox

var push_strength: float = 1000.0
var hitstun_duration: float = 2.5


func _ready() -> void:
	push_strength_box.init("float", "1000.0", -9999999.9, 99999999.9)
	push_strength_box.return_line.connect(_change_push_strength)
	hitstun_duration_box.init("float", "2.5", 0.0, 99999999.9)
	hitstun_duration_box.return_line.connect(_change_hitstun_duration)


func _change_push_strength(new_push_strength: float):
	push_strength = new_push_strength
	emit_signal("hurt_options_changed", {"push_strength": push_strength, "hitstun_duration": hitstun_duration})


func set_push_strength(new_push_strength: float):
	push_strength_box._update_text(str(new_push_strength))
	push_strength = clamp(new_push_strength, -9999999.9, 99999999.9)


func _change_hitstun_duration(new_hitstun_duration: float):
	hitstun_duration = new_hitstun_duration
	emit_signal("hurt_options_changed", {"push_strength": push_strength, "hitstun_duration": hitstun_duration})


func set_hitstun_duration(new_hitstun_duration: float):
	hitstun_duration_box._update_text(str(new_hitstun_duration))
	hitstun_duration = clamp(new_hitstun_duration, 0.0, 99999999.9)
