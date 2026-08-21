extends ButtonPopup

var blockpicker = preload("res://ui/blockpicker.tscn")

var blockpicker_node = null
var blockpicker_func = null


func _ready() -> void:
	super()
	set_intrusive(false)
	set_auto_position(false)
	set_die_without_focus(true)
	blockpicker_node = blockpicker.instantiate()
	add_node_to_holder(blockpicker_node)
	blockpicker_node.block_selected.connect(_block_selected)
	blockpicker_node._change_tab(0)


func init(init_params: Dictionary):
	var block_id = ""
	var current_data = {}
	if "blockpicker_func" in init_params:
		blockpicker_func = init_params.blockpicker_func
	if "block_id" in init_params:
		block_id = init_params.block_id
		#blockpicker_node.go_to_page_with_block_id(block_id)
	if "popup_position" in init_params:
		popup.position = init_params.popup_position


func _block_selected(block_data: Dictionary):
	if blockpicker_func:
		blockpicker_func.call(block_data)
	queue_free()
