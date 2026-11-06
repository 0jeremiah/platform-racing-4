extends ButtonPopup

@onready var layer_name_panel_scene = preload("res://engine/layer_panel/layer_name_panel/layer_name_panel.tscn")

var layer_name_panel_node = null
var layer_name_panel_func = null


func _ready() -> void:
	super()
	set_intrusive(false)
	set_auto_position(false)
	set_die_without_focus(true)
	set_padding(Vector2(0.0, 0.0))
	set_panel_is_visible(false)
	layer_name_panel_node = layer_name_panel_scene.instantiate()
	add_node_to_holder(layer_name_panel_node)
	layer_name_panel_node.set_layer_name.connect(_set_layer_name)


func init(init_params: Dictionary):
	if "popup_global_position" in init_params:
		set_popup_global_position(init_params.popup_global_position)
	if "layer_name_panel_func" in init_params:
		layer_name_panel_func = init_params.layer_name_panel_func
	if "layer_name" in init_params:
		layer_name_panel_node.set_layer_name_string(init_params.layer_name)
	if "layer_name_panel_size" in init_params:
		layer_name_panel_node.set_rename_layer_panel_size(init_params.layer_name_panel_size)


func _set_layer_name(new_layer_name: String):
	if layer_name_panel_func is Callable:
		layer_name_panel_func.call(new_layer_name)
	queue_free()
