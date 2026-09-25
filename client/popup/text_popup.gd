extends ButtonPopup
class_name TextPopup

var popup_text = RichTextLabel.new()


func _ready() -> void:
	super()
	popup_text.fit_content = true
	popup_text.size = Vector2(700, 60)
	add_node_to_holder(popup_text)


func set_text_width(new_text_width: float) -> void:
	popup_text.size.x = new_text_width


func set_text(new_text: String) -> void:
	popup_text.text = new_text
