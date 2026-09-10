extends ButtonPopup

var stamppicker = preload("res://ui/stamppicker.tscn")

var stamppicker_node = null
var stamppicker_func = null


func _ready() -> void:
	super()
	set_intrusive(false)
	set_auto_position(false)
	set_die_without_focus(true)
	stamppicker_node = stamppicker.instantiate()
	add_node_to_holder(stamppicker_node)
	stamppicker_node.stamp_selected.connect(_stamp_selected)
	stamppicker_node._change_tab(0)


func init(init_params: Dictionary):
	var stamp_id = ""
	if "stamppicker_func" in init_params:
		stamppicker_func = init_params.stamppicker_func
	if "stamp_id" in init_params:
		stamp_id = init_params.stamp_id
	if "popup_position" in init_params:
		popup.position = init_params.popup_position


func _stamp_selected(stamp_data: Dictionary):
	if stamppicker_func:
		stamppicker_func.call(stamp_data)
	queue_free()
