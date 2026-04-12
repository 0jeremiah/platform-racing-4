extends ButtonPopup

@onready var register = preload("res://pages/title/register/register.tscn")

var register_node = null


func _ready() -> void:
	super()
	register_node = register.instantiate()
	add_node_to_holder(register_node)
	create_button("Create Account", Callable(self, "_create_account"))
	create_button("Cancel", Callable(self, "_cancel"))


#func init(init_params: Dictionary):
	#var mode = ""
	#var current_data = {}
	#if "mode" in init_params:
		#mode = init_params.mode
	#if "current_data" in init_params:
		#current_data = init_params.current_data
	#if !mode.is_empty() and !current_data.is_empty():
		#save_panel_node.init(mode, current_data)


func _create_account():
	# registering popup code goes here
	queue_free()


func _cancel():
	queue_free()
