extends ButtonPopup

var lister = preload("res://lister/lister.tscn")
var fontpicker_script = preload("res://lister/font_selector.gd")

var lister_node = null
var fontpicker_func = null


func _ready() -> void:
	super()
	set_intrusive(false)
	set_auto_position(false)
	set_die_without_focus(true)
	lister_node = lister.instantiate()
	lister_node.set_script(fontpicker_script)
	add_node_to_holder(lister_node)
	lister_node.font_selected.connect(_font_selected)
	lister_node.show_fonts()


func init(init_params: Dictionary):
	if "fontpicker_func" in init_params:
		fontpicker_func = init_params.fontpicker_func
	if "popup_position" in init_params:
		popup.position = init_params.popup_position


func _font_selected(font_data: Dictionary):
	if fontpicker_func:
		fontpicker_func.call(font_data)
	queue_free()
