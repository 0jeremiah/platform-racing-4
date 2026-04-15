extends TileOptions
class_name TeleportOptions

var color: Color = Color("ff7f50")


func set_color(new_color: Color):
	color = new_color
	data = [color]
