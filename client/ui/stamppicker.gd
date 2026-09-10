extends Control

signal stamp_clicked
signal stamp_selected
signal change_selected_stamp

@onready var tab_bar = $TabBar
@onready var stamp_selector = $StampSelector

var stamp_button = preload("res://stamps/stamp_button.tscn")
var selected_category: String = "general"
var stamp_picker_pages: int = 1
var stamp_picker_page: int = 1
var current_stamp_list: Array = []
var stamps_container_width: int = 10
var stamps_container_height: int = 4
var stamp_picker_pagination_max_buttons: int = 6


func _ready() -> void:
	tab_bar.tab_changed.connect(_change_tab)
	stamp_selector.stamp_clicked.connect(_click_stamp)
	stamp_selector.stamp_selected.connect(_select_stamp)


func _process(_delta: float) -> void:
	size = Vector2(stamp_selector.size.x + stamp_selector.position.x, stamp_selector.size.y + stamp_selector.position.y)


func _change_tab(new_index: int):
	match new_index:
		0: selected_category = "general"
		1: selected_category = "blocks"
		2: selected_category = "custom"
	stamp_selector.change_category(selected_category)


func _click_stamp(stamp_data: Dictionary) -> void:
	if stamp_data.has("id"):
		emit_signal("stamp_clicked", stamp_data)


func _set_current_stamp(stamp_data: Dictionary) -> void:
	if stamp_data.has("id"):
		emit_signal("change_selected_stamp", stamp_data)


func _select_stamp(stamp_data: Dictionary) -> void:
	if stamp_data.has("id"):
		emit_signal("stamp_selected", stamp_data)
