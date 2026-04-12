extends TextPopup
class_name MessagePopup

var popup_message: String = "Evil aliens are stealing our ideas for flavor texts. We will deal with them as quickly as possible."


func _ready() -> void:
	super()
	set_text(popup_message)
	create_button("OK", Callable(self, "_ok"))


func _ok() -> void:
	queue_free()
