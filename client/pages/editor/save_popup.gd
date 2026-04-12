extends ButtonPopup

@onready var save = preload("res://pages/editor/save/save.tscn")

var save_node = null


func _ready() -> void:
	super()
	save_node = save.instantiate()
	add_node_to_holder(save_node)
	create_button("Save", Callable(self, "_save"))
	create_button("Cancel", Callable(self, "_cancel"))


func init(init_params: Dictionary):
	var mode = ""
	var current_data = {}
	if "mode" in init_params:
		mode = init_params.mode
	if "current_data" in init_params:
		current_data = init_params.current_data
	if !mode.is_empty() and !current_data.is_empty():
		save_node.init(mode, current_data)


func _save():
	# saving code goes here
	queue_free()


func _cancel():
	# saving code goes here
	queue_free()
