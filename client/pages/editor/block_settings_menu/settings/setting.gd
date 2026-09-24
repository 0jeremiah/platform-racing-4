extends Control
class_name BlockSetting

signal setting_changed

var key: String = ""
var settings: Dictionary = {}


func set_key(new_key: String):
	key = new_key


func connect_node(node, signal_name: String):
	node.connect(signal_name, _update_setting)


func _update_setting(new_side_settings: Dictionary):
	settings = new_side_settings
	if key:
		emit_signal("setting_changed", {"settings": settings})
