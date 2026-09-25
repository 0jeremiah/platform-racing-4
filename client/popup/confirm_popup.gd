extends TextPopup
class_name ConfirmPopup

var confirm_func = null
var popup_message: String = "Are you sure?"


func _ready() -> void:
	super()
	set_text(popup_message)
	create_button("OK", Callable(self, "_ok"))
	create_button("Cancel", Callable(self, "_cancel"))


func _ok() -> void:
	if confirm_func is Callable:
		confirm_func.call()
	queue_free()


func _cancel() -> void:
	queue_free()
