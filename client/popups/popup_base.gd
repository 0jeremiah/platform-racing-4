extends Control
class_name PopupManager

@onready var intrusive_bg = $IntrusiveBG
@onready var panel = $Panel

var intrusive: bool = true
var target_alpha: float = 1.0
var available_size: Vector2 = get_viewport().get_visible_rect().size
var padding: float = 20.0
var auto_position: bool = true
