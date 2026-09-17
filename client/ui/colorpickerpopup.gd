extends ButtonPopup

var colorpicker = preload("res://ui/colorpicker.tscn")

var colorpicker_node = null
var colorpicker_func = null


func _ready() -> void:
	super()
	set_intrusive(false)
	set_auto_position(false)
	set_die_without_focus(true)
	colorpicker_node = colorpicker.instantiate()
	add_node_to_holder(colorpicker_node)
	colorpicker_node.set_new_color.connect(_color_picked)
	colorpicker_node.cancel_pressed.connect(queue_free)


func init(init_params: Dictionary):
	if "colorpicker_func" in init_params:
		colorpicker_func = init_params.colorpicker_func
	if "previous_color" in init_params:
		colorpicker_node.set_previous_color(init_params.previous_color)
	if "popup_position" in init_params:
		popup.position = init_params.popup_position


func _color_picked(new_color: Color):
	if colorpicker_func:
		colorpicker_func.call(new_color)
	queue_free()
