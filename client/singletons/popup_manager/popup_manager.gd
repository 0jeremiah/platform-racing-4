extends Node
## Handles popups. Adds the popups seen in PR2/PR3.

@onready var popups = $Popups

var popup_base = preload("res://ui/popup/popup.tscn")
var message_popup = preload("res://ui/popup/message_popup.gd")
var confirm_popup = preload("res://ui/popup/confirm_popup.gd")


func add_message_popup(popup_message: String = ""):
	var popup = popup_base.instantiate()
	popup.set_script(message_popup)
	if !popup_message.is_empty():
		popup.popup_message = popup_message
	popups.add_child(popup)


func add_confirm_popup(confirm_func = null, popup_message: String = ""):
	var popup = popup_base.instantiate()
	popup.set_script(confirm_popup)
	if confirm_func is Callable:
		popup.confirm_func = confirm_func
	if !popup_message.is_empty():
		popup.popup_message = popup_message
	popups.add_child(popup)


func add_custom_popup(custom_popup_code: Script, init_params = null):
	var popup = popup_base.instantiate()
	popup.set_script(custom_popup_code)
	popups.add_child(popup)
	if popup.has_method("init") and init_params != null:
		popup.init(init_params)


func delete_all_popups():
	for popup in popups.get_children():
		popup.queue_free()
