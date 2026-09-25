extends Node
## Handles popups. Adds the popups seen in PR2/PR3.

@onready var popups = $Popups

var popup_base = preload("res://popup/popup.tscn")
var message_popup = preload("res://popup/message_popup.gd")
var confirm_popup = preload("res://popup/confirm_popup.gd")


func add_message_popup(popup_message: String = "", at_node: Node = null):
	#var viewport = get_viewport()
	#if viewport:
		#viewport.gui_release_focus()
	var popup = popup_base.instantiate()
	popup.set_script(message_popup)
	if !popup_message.is_empty():
		popup.popup_message = popup_message
	if at_node:
		at_node.add_child(popup)
	else:
		popups.add_child(popup)
	popup.popup.grab_focus()


func add_confirm_popup(confirm_func = null, popup_message: String = "", at_node: Node = null):
	#var viewport = get_viewport()
	#if viewport:
		#viewport.gui_release_focus()
	var popup = popup_base.instantiate()
	popup.set_script(confirm_popup)
	if confirm_func is Callable:
		popup.confirm_func = confirm_func
	if !popup_message.is_empty():
		popup.popup_message = popup_message
	if at_node:
		at_node.add_child(popup)
	else:
		popups.add_child(popup)
	popup.popup.grab_focus()


func add_custom_popup(custom_popup_code: Script, init_params = null, at_node: Node = null):
	#var viewport = get_viewport()
	#if viewport:
		#viewport.gui_release_focus()
	var popup = popup_base.instantiate()
	popup.set_script(custom_popup_code)
	if at_node:
		at_node.add_child(popup)
	else:
		popups.add_child(popup)
	if popup.has_method("init") and init_params != null:
		popup.init(init_params)
	popup.popup.grab_focus()


func delete_all_popups():
	for popup in popups.get_children():
		popup.queue_free()
