extends ButtonPopup

var dropdownpicker = preload("res://ui/dropdown/dropdownpicker.tscn")

var dropdownpicker_node = null
var dropdownpicker_func = null


func _ready() -> void:
	super()
	set_intrusive(false)
	set_auto_position(false)
	set_die_without_focus(true)
	dropdownpicker_node = dropdownpicker.instantiate()
	add_node_to_holder(dropdownpicker_node)
	dropdownpicker_node.dropdown_selected.connect(_dropdown_selected)


func init(init_params: Dictionary):
	if "dropdownpicker_func" in init_params:
		dropdownpicker_func = init_params.dropdownpicker_func
	if "dropdown_size" in init_params:
		dropdownpicker_node.set_dropdown_size(init_params.dropdown_size)
	if "options" in init_params:
		if init_params.options is Dictionary:
			dropdownpicker_node.add_options_from_dictionary(init_params.options)
		elif init_params.options is Array:
			dropdownpicker_node.add_options_from_array(init_params.options)
	if "popup_position" in init_params:
		popup.position = init_params.popup_position


func _dropdown_selected(dropdown_data: Dictionary):
	if dropdownpicker_func:
		dropdownpicker_func.call(dropdown_data)
	queue_free()
