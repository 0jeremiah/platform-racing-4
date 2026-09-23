extends ButtonPopup

var blockpicker = preload("res://ui/blockpicker.tscn")

var blockpicker_node = null
var blockpicker_func = null
var blockpicker_clicked_func = null
var close_after_select: bool = true


func _ready() -> void:
	super()
	set_intrusive(false)
	set_auto_position(false)
	set_die_without_focus(true)
	blockpicker_node = blockpicker.instantiate()
	add_node_to_holder(blockpicker_node)
	blockpicker_node.block_clicked.connect(_block_clicked)
	blockpicker_node.block_selected.connect(_block_selected)


func init(init_params: Dictionary):
	if "blockpicker_func" in init_params:
		blockpicker_func = init_params.blockpicker_func
	if "blockpicker_clicked_func" in init_params:
		blockpicker_clicked_func = init_params.blockpicker_clicked_func
	if "close_after_select" in init_params:
		close_after_select = init_params.close_after_select
	if "popup_position" in init_params:
		popup.position = init_params.popup_position
	if "send_block_picker_size_and_position_func" in init_params:
		init_params.send_block_picker_size_and_position_func.call({"position": holder.global_position + blockpicker_node.block_selector.list_container.global_position, "size": blockpicker_node.size})


func _block_clicked(block_data: Dictionary):
	if blockpicker_clicked_func:
		blockpicker_clicked_func.call(block_data)


func _block_selected(block_data: Dictionary):
	if blockpicker_func:
		blockpicker_func.call(block_data)
	if close_after_select:
		queue_free()
