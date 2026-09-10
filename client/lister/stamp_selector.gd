extends Selector
class_name StampSelector

signal stamp_clicked
signal stamp_selected

var stamp_button = preload("res://stamps/stamp_button.tscn")
var request_array: Array = []
var selected_category: String = "general"
var custom_list: Array = []
var stamp_rows: int = 4
var stamp_columns: int = 10


func _ready() -> void:
	super()
	cache_slug = "my_stamps"
	cache_seconds = 60 * 60
	pagination_slug = "stampselector-" + selected_category
	set_columns(stamp_columns)
	set_results_per_page(stamp_rows * stamp_columns)
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
	add_stamps(truncated_list)


func change_category(new_category: String):
	pagination_slug = ""
	list = []
	if new_category in StampManager._stamp_categories:
		selected_category = new_category
		if new_category == "custom":
			cache_slug = "my_stamps"
		else:
			cache_slug = ""
		pagination_slug = "stampselector-" + selected_category
		var block_list = StampManager._stamp_categories.get(selected_category, [])
		list = block_list
		request_array = []
		for block in list:
			request_array.push_back(block.id)
	set_total_results(list.size())
	set_page(get_last_remembered_page())
	display_list(list)


func add_stamp(stamp_id: String):
	if stamp_id in StampManager._stamp_lookup:
		var new_stamp_button = stamp_button.instantiate()
		new_stamp_button.stamp_clicked.connect(click_stamp)
		new_stamp_button.stamp_selected.connect(select_stamp)
		new_stamp_button.tooltip_text = StampManager._stamp_lookup[stamp_id].title + "\n" + StampManager._stamp_lookup[stamp_id].comment
		add_node(new_stamp_button)
		new_stamp_button.init(stamp_id)


func add_stamps(stamp_array: Array):
	for stamp in stamp_array:
		add_stamp(stamp.id)


func click_stamp(stamp_data: Dictionary):
	emit_signal("stamp_clicked", stamp_data)


func select_stamp(stamp_data: Dictionary):
	emit_signal("stamp_selected", stamp_data)
