extends Button

var button_label: String = ""
var data = null


func set_button(new_button_label: String, new_data = null):
	button_label = new_button_label
	data = new_data
	text = button_label
