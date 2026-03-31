extends SideOption

signal ice_options_changed

@onready var ice_friction_box = $IceFrictionBox

var ice_friction: float = 0.2


func _ready() -> void:
	ice_friction_box.init("float", "0.2", -9999999.9, 99999999.9)
	ice_friction_box.return_line.connect(_change_ice_friction)
	connect_node(self, "ice_options_changed")


func _change_ice_friction(new_ice_friction: float):
	ice_friction = new_ice_friction
	emit_signal("ice_options_changed", {"ice_friction": ice_friction})


func set_options(new_options: Dictionary):
	if new_options.has("ice_friction"):
		ice_friction = clamp(new_options.ice_friction, -9999999.9, 99999999.9)
		ice_friction_box._update_text(str(ice_friction))
	options = {"ice_friction": ice_friction}
