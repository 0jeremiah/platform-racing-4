extends Control
class_name BlockSideSetting

signal side_setting_changed

var category: String = ""
var side: String = ""
var key: String = ""
var side_settings: Dictionary = {}


func set_category(new_category: String):
	category = new_category


func set_side(new_side: String):
	side = new_side


func set_key(new_key: String):
	key = new_key


func connect_node(node, signal_name: String):
	node.connect(signal_name, _update_side_setting.bind())


func _update_side_setting(new_side_settings: Dictionary):
	side_settings = new_side_settings
	if key:
		emit_signal("side_setting_changed", {"category": category, "side": side, "side_settings": side_settings})
