#extends IconButton
#
#var default_texture = load("res://icon.svg")
#var colors = {
	#"bg": Color("ffffff"),
	#"icon": Color("ffffff")
#}
#var editor_events: Node2D
#
	#
#func _ready() -> void:
	#if LevelEditor.level_editor:
		#editor_events = LevelEditor.level_editor.get_node("EditorEvents")
		#editor_events.editor_event.connect(_editor_event)
	#init(default_texture, colors, colors)
#
#
#func _editor_event(event: Dictionary) -> void:
	#pass
