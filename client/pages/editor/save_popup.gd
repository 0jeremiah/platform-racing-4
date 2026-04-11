extends ButtonPopup

@onready var save_panel = preload("res://pages/editor/save_panel.tscn")


func _ready() -> void:
	modulate.a = 0.0
	screen_size = get_viewport().get_visible_rect().size
	var save_panel_node = save_panel.instantiate()
	add_node_to_holder(save_panel_node)
	create_button("Save", Callable(self, "_save"))
	create_button("Cancel", Callable(self, "_cancel"))


func _save():
	# saving code goes here
	queue_free()


func _cancel():
	# saving code goes here
	queue_free()
