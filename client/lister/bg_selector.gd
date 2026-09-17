extends Selector
class_name BGSelector

signal bg_selected

var color_picker_popup = preload("res://ui/colorpickerpopup.gd")
var color_box = preload("res://ui/colorbutton.tscn")
var bg_button = preload("res://engine/bg/bg_button.tscn")
var bg_rows: int = 3
var bg_columns: int = 5
var bg_color: Color = Color(1.0, 1.0, 1.0)
var colorpicker_func = null
var popup_position = Vector2(0.0, 0.0)


func _ready() -> void:
	super()
	cache_seconds = 60 * 60
	pagination_slug = "bgselector-"
	set_columns(bg_columns)
	set_results_per_page(bg_rows * bg_columns)
	set_lister_width(300)
	set_lister_height(180)
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
	add_bgs(truncated_list)


func show_bgs():
	list = Backgrounds.bg_dictionary.keys()
	set_total_results(list.size())
	set_page(get_last_remembered_page())
	display_list(list)


func add_bg(bg_id: String):
	if bg_id == "blank":
		var new_bg_button = bg_button.instantiate()
		new_bg_button.bg_selected.connect(call_colorpicker_popup)
		new_bg_button.name = "blank"
		add_node(new_bg_button)
		new_bg_button.init(bg_id)
		new_bg_button.self_modulate = bg_color
	elif bg_id in Backgrounds.bg_dictionary:
		var new_bg_button = bg_button.instantiate()
		new_bg_button.bg_selected.connect(select_bg)
		add_node(new_bg_button)
		new_bg_button.init(bg_id)


func set_bg_color(new_bg_color: Color):
	bg_color = new_bg_color
	var bg_color_button = list_container.get_node_or_null("blank")
	if bg_color_button:
		bg_color_button.modulate = bg_color


func add_bgs(bg_array: Array):
	for bg in bg_array:
		add_bg(bg)


func call_colorpicker_popup(_new_bg_id: String = "blank"):
	if colorpicker_func:
		PopupManager.add_custom_popup(color_picker_popup, {"colorpicker_func": colorpicker_func, "previous_color": bg_color, "popup_position": popup_position})


func select_bg(new_bg_id: String):
	emit_signal("bg_selected", new_bg_id)
