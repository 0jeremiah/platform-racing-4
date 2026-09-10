extends Selector
class_name FontSelector

signal font_clicked
signal font_selected

var font_button = preload("res://fonts/font_button.tscn")
var request_array: Array = []
var stamp_rows: int = 5
var stamp_columns: int = 1


func _ready() -> void:
	super()
	cache_seconds = 60 * 60
	pagination_slug = "fontselector-"
	set_columns(stamp_columns)
	set_results_per_page(stamp_rows * stamp_columns)
	set_lister_width(300)
	set_lister_height(200)
	set_lister_h_separation(0)
	set_lister_v_separation(0)
	set_page(get_last_remembered_page())
	pagination.init(1, 0, 6, false)
	pagination.update_display()


func display_list(list_array: Array):
	for child in list_container.get_children():
		child.queue_free()
	loading_text.visible = false
	no_results_found_text.visible = false
	if list_array.is_empty():
		no_results_found_text.visible = true
	var truncated_list = list_array.slice(results_per_page * (page - 1), results_per_page * page)
	add_fonts(truncated_list)


func show_fonts():
	list = FontManager.font_list.keys()
	set_total_results(list.size())
	set_page(get_last_remembered_page())
	display_list(list)


func add_font(font_id: String):
	if font_id in FontManager.font_list:
		var new_font_button = font_button.instantiate()
		new_font_button.font_clicked.connect(click_font)
		new_font_button.font_selected.connect(select_font)
		add_node(new_font_button)
		new_font_button.init(font_id)


func add_fonts(font_array: Array):
	for font in font_array:
		add_font(font)


func click_font(font_data: Dictionary):
	emit_signal("font_clicked", font_data)


func select_font(font_data: Dictionary):
	emit_signal("font_selected", font_data)
