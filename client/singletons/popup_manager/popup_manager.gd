extends Node
## Handles popups. Adds the popups seen in PR2/PR3.

var button_popup = preload("res://ui/popup/button_popup.tscn")
var text_popup = preload("res://ui/popup/text_popup.tscn")


func _process(_delta: float) -> void:
	if get_node("/root").get_node("PopupManager").get_index() < get_node("/root").get_child_count() - 1:
		get_node("/root").move_child(get_node("/root").get_node("PopupManager"), get_node("/root").get_child_count())


func add_message_popup(popup_message: String):
	var popup = text_popup.instantiate()
	add_child(popup)
	popup.set_text(popup_message)
	popup.create_button("OK")


func add_confirm_popup(confirm_func = null, popup_message: String = "Are you sure?"):
	var popup = text_popup.instantiate()
	add_child(popup)
	popup.set_text(popup_message)
	popup.create_button("OK", confirm_func)
	popup.create_button("Cancel")
