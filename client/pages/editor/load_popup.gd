extends ButtonPopup

@onready var load_scene = preload("res://pages/editor/load/load.tscn")

var load_node = null
var load_func = null


func _ready() -> void:
	super()
	load_node = load_scene.instantiate()
	add_node_to_holder(load_node)
	create_button("Load", Callable(self, "_load"))
	create_button("Delete", Callable(self, "_maybe_delete"))
	create_button("Cancel", Callable(self, "_cancel"))


func init(init_params: Dictionary):
	if "mode" in init_params:
		load_node.init(init_params.mode)
	if "load_func" in init_params:
		load_func = init_params.load_func


func _load():
	var load_params = load_node.get_load_params()
	if load_func is Callable:
		load_func.call(load_params.folder, load_params.title, load_params.description)
	queue_free()


func _maybe_delete():
	# deleting level code goes here
	pass


func _cancel():
	queue_free()
