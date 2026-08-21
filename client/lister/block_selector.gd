extends Selector
class_name BlockSelector

signal block_clicked
signal block_selected

var block_button = preload("res://blocks/block_button.tscn")
var request_array: Array = []
var selected_category: String = "pr4"
var custom_list: Array = []
var block_rows: int = 4
var block_columns: int = 10


func _ready() -> void:
	super()
	cache_slug = "my_blocks"
	cache_seconds = 60 * 60
	pagination_slug = "blockselector-" + selected_category
	set_columns(block_columns)
	set_results_per_page(block_rows * block_columns)
	set_lister_width(600)
	set_lister_height(240)
	set_lister_h_separation(0)
	set_lister_v_separation(0)
	set_page(get_last_remembered_page())
	pagination.init(1, 0, 6, false)
	pagination.update_display()
	# code to check if we are logged in and get custom blocks from there goes here


func display_list(list_array: Array):
	for child in list_container.get_children():
		child.queue_free()
	loading_text.visible = false
	no_results_found_text.visible = false
	if list_array.is_empty():
		no_results_found_text.visible = true
	var truncated_list = list_array.slice(results_per_page * (page - 1), results_per_page * page)
	add_blocks(truncated_list)


func change_category(new_category: String):
	pagination_slug = ""
	list = []
	if new_category in BlockManager._blocks_categories:
		selected_category = new_category
		if new_category == "custom":
			cache_slug = "my_blocks"
		else:
			cache_slug = ""
		pagination_slug = "blockselector-" + selected_category
		var block_list = BlockManager._blocks_categories.get(selected_category, [])
		list = block_list
		request_array = []
		for block in list:
			request_array.push_back(block.id)
	set_total_results(list.size())
	set_page(get_last_remembered_page())
	display_list(list)


func add_block(block_id: String):
	if block_id in BlockManager._block_lookup:
		var tile_settings = BlockManager._block_lookup[block_id].settings
		var new_block_button = block_button.instantiate()
		new_block_button.block_clicked.connect(click_block)
		new_block_button.block_selected.connect(select_block)
		new_block_button.tooltip_text = BlockManager._block_lookup[block_id].title + "\n" + BlockManager._block_lookup[block_id].comment
		add_node(new_block_button)
		new_block_button.init(block_id, tile_settings)


func add_blocks(block_array: Array):
	for block in block_array:
		add_block(block.id)


func click_block(block_data: Dictionary):
	emit_signal("block_clicked", block_data)


func select_block(block_data: Dictionary):
	emit_signal("block_selected", block_data)
