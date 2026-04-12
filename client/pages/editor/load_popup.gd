extends ButtonPopup

@onready var load = preload("res://pages/editor/load/load.tscn")

var load_node = null


func _ready() -> void:
	super()
	load_node = load.instantiate()
	add_node_to_holder(load_node)
	create_button("Load", Callable(self, "_load"))
	create_button("Delete", Callable(self, "_maybe_delete"))
	create_button("Cancel", Callable(self, "_cancel"))


#func init(init_params: Dictionary):
	#var mode = ""
	#if "mode" in init_params:
		#mode = init_params.mode
	#if !mode.is_empty():
		#load_panel_node.init(mode)


func _load():
	# loading code goes here
	queue_free()


func _maybe_delete():
	# deleting level code goes here
	pass


func _cancel():
	queue_free()
