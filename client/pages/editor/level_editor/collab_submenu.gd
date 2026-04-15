extends Control

var active: bool = false


func _ready() -> void:
	pass


func deactivate():
	active = false


func activate():
	active = true


func _process(_delta: float) -> void:
	if active:
		visible = true
	else:
		visible = false
