extends Control

signal block_clicked
signal block_selected
signal change_selected_block

@onready var tab_bar = $TabBar
@onready var block_selector = $BlockSelector

var texture: Texture2D = preload("res://tiles/tileatlas.png")
var block_button = preload("res://blocks/block_button.tscn")
var selected_category: String = "pr4"
var block_picker_pages: int = 1
var block_picker_page: int = 1
var current_block_list: Array = []
var blocks_container_width: int = 10
var blocks_container_height: int = 4
var block_picker_pagination_max_buttons: int = 6


func _ready() -> void:
	tab_bar.tab_changed.connect(_change_tab)
	block_selector.block_clicked.connect(_click_block)
	block_selector.block_selected.connect(_select_block)


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


func _click_block(block_data: Dictionary) -> void:
	if block_data.has("id"):
		emit_signal("block_clicked", block_data)


func _set_current_block(block_data: Dictionary) -> void:
	if block_data.has("id"):
		emit_signal("change_selected_block", block_data)


func _select_block(block_data: Dictionary) -> void:
	if block_data.has("id"):
		emit_signal("block_selected", block_data)
