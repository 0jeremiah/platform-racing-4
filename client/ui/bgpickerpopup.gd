extends ButtonPopup

var lister = preload("res://lister/lister.tscn")
var bgpicker_script = preload("res://lister/bg_selector.gd")

var lister_node = null
var bgpicker_func = null


func _ready() -> void:
	super()
	set_intrusive(false)
	set_auto_position(false)
	set_die_without_focus(true)
	lister_node = lister.instantiate()
	lister_node.set_script(bgpicker_script)
	add_node_to_holder(lister_node)
	lister_node.bg_selected.connect(_bg_selected)


func init(init_params: Dictionary):
	if "bgpicker_func" in init_params:
		bgpicker_func = init_params.bgpicker_func
	if "colorpicker_func" in init_params:
		lister_node.colorpicker_func = init_params.colorpicker_func
	if "bg_color" in init_params:
		lister_node.set_bg_color(init_params.bg_color)
	if "popup_position" in init_params:
		popup.position = init_params.popup_position
		lister_node.popup_position = init_params.popup_position


func _bg_selected(bg_id: String):
	if bgpicker_func:
		bgpicker_func.call(bg_id)
	queue_free()
