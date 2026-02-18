extends TileOptions
class_name TeleportOptions

var color: Color = Color("ff7f50")
var teleport_popup = preload("res://popups/teleportoptionspopup.tscn")


func set_color(new_color: Color):
	color = new_color
	data = [color]
