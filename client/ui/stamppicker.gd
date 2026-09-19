extends Control

signal stamp_clicked
signal stamp_selected
signal change_selected_stamp

@onready var tab_bar = $TabBar
@onready var stamp_selector = $StampSelector

static var selected_category: String = "general"


func _ready() -> void:
	tab_bar.tab_changed.connect(_change_tab)
	stamp_selector.stamp_clicked.connect(_click_stamp)
	stamp_selector.stamp_selected.connect(_select_stamp)
	match_tab(selected_category)


func _process(_delta: float) -> void:
	size = Vector2(stamp_selector.size.x + stamp_selector.position.x, stamp_selector.size.y + stamp_selector.position.y)


func _change_tab(new_index: int):
	match new_index:
		0: selected_category = "general"
		1: selected_category = "blocks"
		2: selected_category = "custom"
	stamp_selector.change_category(selected_category)


func match_tab(new_selected_category: String):
	var index = -1
	match new_selected_category:
		"general": index = 0
		"blocks": index = 1
		"custom": index = 2
	if index >= 0:
		tab_bar.current_tab = index
	stamp_selector.change_category(new_selected_category)


func _click_stamp(stamp_data: Dictionary) -> void:
	if stamp_data.has("id"):
		emit_signal("stamp_clicked", stamp_data)


func _set_current_stamp(stamp_data: Dictionary) -> void:
	if stamp_data.has("id"):
		emit_signal("change_selected_stamp", stamp_data)


func _select_stamp(stamp_data: Dictionary) -> void:
	if stamp_data.has("id"):
		emit_signal("stamp_selected", stamp_data)
