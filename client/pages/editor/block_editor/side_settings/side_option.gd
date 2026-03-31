extends Control
class_name SideOption

signal side_option_changed

var side: String = ""
var key: String = ""
var options: Dictionary = {}
var options_signal: String = ""


func set_side(new_side: String):
	side = new_side


func set_key(new_key: String):
	key = new_key


func connect_node(node, signal_name: String):
	node.connect(signal_name, _update_options)


func _update_options(new_options: Dictionary):
	options = new_options
	if key:
		emit_signal("side_option_changed", {"side": side, "options": options})
