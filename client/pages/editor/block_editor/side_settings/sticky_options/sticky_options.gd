extends SideOption

signal stick_options_changed

@onready var stickiness_box = $StickinessBox

var stickiness: float = 2.5


func _ready() -> void:
	stickiness_box.init("float", "2.5", 0.0, 99999999.9)
	stickiness_box.return_line.connect(_change_stickiness)
	connect_node(self, "stick_options_changed")


func _change_stickiness(new_stickiness: float):
	stickiness = new_stickiness
	emit_signal("stick_options_changed", {"stickiness": stickiness})


func set_options(new_options: Dictionary):
	if new_options.has("stickiness"):
		stickiness = clamp(new_options.stickiness, 0.0, 99999999.9)
		stickiness_box._update_text(str(stickiness))
	options = {"stickiness": stickiness}
