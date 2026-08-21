extends Button

var button_func = null


func set_button(new_button_text: String, new_button_func = null):
	text = new_button_text
	if new_button_func is Callable:
		button_func = new_button_func
