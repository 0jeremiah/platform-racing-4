extends ButtonPopup

@onready var stamp_mode_scene = preload("res://pages/editor/setting_popups/stamp_mode/stamp_mode.tscn")

var stamp_mode_node = null
var stamp_mode_func = null


func _ready() -> void:
	super()
	set_intrusive(false)
	set_auto_position(false)
	set_die_without_focus(true)
	stamp_mode_node = stamp_mode_scene.instantiate()
	add_node_to_holder(stamp_mode_node)
	stamp_mode_node.stamp_mode_changed.connect(_select_stamp_mode)


func init(init_params: Dictionary):
	if "popup_position" in init_params:
		popup.position = init_params.popup_position
	if "stamp_mode_func" in init_params:
		stamp_mode_func = init_params.stamp_mode_func
	if "stamp_mode" in init_params:
		stamp_mode_node._set_stamp_mode_tab(init_params.stamp_mode)


func _select_stamp_mode(new_stamp_mode: String):
	if stamp_mode_func is Callable:
		stamp_mode_func.call(new_stamp_mode)
	queue_free()
