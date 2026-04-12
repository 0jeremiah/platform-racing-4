extends ButtonPopup

@onready var login = preload("res://pages/title/login/login.tscn")

var login_node = null


func _ready() -> void:
	super()
	login_node = login.instantiate()
	add_node_to_holder(login_node)
	create_button("Login", Callable(self, "_login"))
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


func _login():
	# logging in popup code goes here
	queue_free()


func _cancel():
	queue_free()
