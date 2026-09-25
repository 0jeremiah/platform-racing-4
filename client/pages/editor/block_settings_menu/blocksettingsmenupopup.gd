extends ButtonPopup

var blocksettingsmenu = preload("res://pages/editor/block_settings_menu/block_settings_menu.tscn")

var blocksettingsmenu_node = null
var blocksettingsmenu_func = null


func _ready() -> void:
	super()
	set_intrusive(false)
	set_auto_position(false)
	set_die_without_focus(true)
	blocksettingsmenu_node = blocksettingsmenu.instantiate()
	add_node_to_holder(blocksettingsmenu_node)


func init(init_params: Dictionary):
	if "blocksettingsmenu_func" in init_params:
		blocksettingsmenu_func = init_params.blocksettingsmenu_func
	if "block_settings" in init_params:
		blocksettingsmenu_node.init(init_params.block_settings)
	if "popup_position" in init_params:
		popup.position = init_params.popup_position
