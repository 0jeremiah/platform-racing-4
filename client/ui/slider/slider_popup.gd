extends ButtonPopup

@onready var slider_scene = preload("res://ui/slider/slider.tscn")

var slider_node = null
var slider_func = null


func _ready() -> void:
	super()
	set_intrusive(false)
	set_auto_position(false)
	set_die_without_focus(true)
	slider_node = slider_scene.instantiate()
	add_node_to_holder(slider_node)
	slider_node.set_new_slider_value.connect(_send_slider_value)


func init(init_params: Dictionary):
	if "popup_global_position" in init_params:
		set_popup_global_position(init_params.popup_global_position)
	if "init_slider_values" in init_params:
		slider_node.init(init_params.init_slider_values)
	if "slider_func" in init_params:
		slider_func = init_params.slider_func
	if "slider_size" in init_params:
		slider_node.set_slider_size(init_params.slider_size)


func _send_slider_value(slider_data: Dictionary):
	if slider_func is Callable:
		slider_func.call(slider_data.slider_value)
	if slider_data.close_slider_popup:
		queue_free()
