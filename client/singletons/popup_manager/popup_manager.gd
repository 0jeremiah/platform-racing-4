extends Node
## Handles popups. Adds the popups seen in PR2/PR3.

@onready var popups = $Popups

var button_popup = preload("res://ui/popup/button_popup.tscn")
var text_popup = preload("res://ui/popup/text_popup.tscn")


func add_message_popup(popup_message: String):
	var popup = text_popup.instantiate()
	popups.add_child(popup)
	popup.set_text(popup_message)
	popup.create_button("OK")


func add_confirm_popup(confirm_func = null, popup_message: String = "Are you sure?"):
	var popup = text_popup.instantiate()
	popups.add_child(popup)
	popup.set_text(popup_message)
	popup.create_button("OK", confirm_func)
	popup.create_button("Cancel")


func add_custom_popup(custom_popup_code: Script):
	var popup = button_popup.instantiate()
	popup.set_script(custom_popup_code)
	popups.add_child(popup)
