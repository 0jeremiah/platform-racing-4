extends Control

signal block_clicked
signal block_selected
signal change_selected_block

@onready var tab_bar = $TabBar
@onready var block_selector = $BlockSelector

static var selected_category: String = "pr4"


func _ready() -> void:
	tab_bar.tab_changed.connect(_change_tab)
	block_selector.block_clicked.connect(_click_block)
	block_selector.block_selected.connect(_select_block)
	match_tab(selected_category)


func _process(_delta: float) -> void:
	size = Vector2(block_selector.size.x + block_selector.position.x, block_selector.size.y + block_selector.position.y)


func _change_tab(new_index: int):
	match new_index:
		0: selected_category = "pr4"
		1: selected_category = "desert"
		2: selected_category = "industrial"
		3: selected_category = "jungle"
		4: selected_category = "underwater"
		5: selected_category = "space"
		6: selected_category = "pr2"
		7: selected_category = "custom"
	block_selector.change_category(selected_category)


func match_tab(new_selected_category: String):
	var index = -1
	match new_selected_category:
		"pr4": index = 0
		"desert": index = 1
		"industrial": index = 2
		"jungle": index = 3
		"underwater": index = 4
		"space": index = 5
		"pr2": index = 6
		"custom": index = 7
	if index >= 0:
		tab_bar.current_tab = index
	block_selector.change_category(selected_category)


func _click_block(block_data: Dictionary) -> void:
	if block_data.has("id"):
		emit_signal("block_clicked", block_data)


func _set_current_block(block_data: Dictionary) -> void:
	if block_data.has("id"):
		emit_signal("change_selected_block", block_data)


func _select_block(block_data: Dictionary) -> void:
	if block_data.has("id"):
		emit_signal("block_selected", block_data)
