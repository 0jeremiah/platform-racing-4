extends Node2D

@onready var text_1 = $TextContainer/Text1
@onready var text_2 = $TextContainer/Text2
@onready var text_fill = $TextContainer/Text2/TextFill
@onready var text_3 = $TextContainer/Text3


func _process(_delta: float) -> void:
	if text_fill.position.x - 5.0 < -400.0:
		text_fill.position.x = 0.0
	else:
		text_fill.position.x -= 5.0


func set_text(new_text: String):
	text_1.text = new_text
	text_2.text = new_text
	text_3.text = new_text
