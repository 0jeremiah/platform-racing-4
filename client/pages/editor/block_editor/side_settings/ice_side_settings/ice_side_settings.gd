extends BlockSideSetting

signal ice_side_settings_changed

@onready var ice_friction_box = $IceFrictionBox

var ice_friction: float = 0.2


func _ready() -> void:
	ice_friction_box.init("float", "0.2", -9999999.9, 99999999.9)
	ice_friction_box.return_line.connect(_change_ice_friction)
	connect_node(self, "ice_side_settings_changed")


func _change_ice_friction(new_ice_friction: float):
	ice_friction = new_ice_friction
	emit_signal("ice_side_settings_changed", {"ice_friction": ice_friction})


func set_side_settings(new_side_settings: Dictionary):
	if new_side_settings.has("ice_friction"):
		ice_friction = clamp(new_side_settings.ice_friction, -9999999.9, 99999999.9)
		ice_friction_box._update_text(str(ice_friction))
	side_settings = {"ice_friction": ice_friction}
