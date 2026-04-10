extends ButtonPopup
class_name TextPopup

@onready var popup_text = $Popup/Holder/PopupText


func set_text_width(new_text_width: float):
	popup_text.size.x = new_text_width


func set_text(new_text: String):
	popup_text.text = new_text
