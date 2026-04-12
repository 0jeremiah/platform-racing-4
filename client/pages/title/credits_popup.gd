extends ButtonPopup

@onready var credits = preload("res://pages/title/credits/credits.tscn")

var credits_node = null


func _ready() -> void:
	super()
	credits_node = credits.instantiate()
	add_node_to_holder(credits_node)
	create_button("Close", Callable(self, "_close"))


#func init(init_params: Dictionary):
	#var mode = ""
	#var current_data = {}
	#if "mode" in init_params:
		#mode = init_params.mode
	#if "current_data" in init_params:
		#current_data = init_params.current_data
	#if !mode.is_empty() and !current_data.is_empty():
		#save_panel_node.init(mode, current_data)


func _close():
	queue_free()
