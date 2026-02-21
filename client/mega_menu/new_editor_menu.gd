extends Node2D
class_name EditorMenu

signal control_event
signal level_event
signal cursor_is_enabled

@onready var level_options_menu = $LevelOptionsMenu
var layers: Node2D
var editor_events: EditorEvents


func _ready():
	get_viewport().size_changed.connect(_on_size_changed)
	level_options_menu.control_event.connect(_on_control_event)
	level_options_menu.level_event.connect(_on_level_event)
	level_options_menu.cursor_is_enabled.connect(_on_cursor_is_enabled.bind())
	_on_size_changed()


func init(new_layers: Node2D, new_editor_events: EditorEvents) -> void:
	layers = new_layers
	editor_events = new_editor_events
	level_options_menu.init(layers, editor_events)


func set_editor_mode(current_editor):
	level_options_menu.editor = current_editor


func _on_size_changed():
	var window_size = get_viewport().get_visible_rect().size
	if window_size.x > 0 and window_size.y > 0:
		position = Vector2(0, 0)


func _on_control_event(event: Dictionary) -> void:
	print("EditorMenu::_on_control_event ", event)
	control_event.emit(event)
	

func _on_level_event(event: Dictionary) -> void:
	print("EditorMenu::_on_level_event ", event)
	level_event.emit(event)


func _on_cursor_is_enabled(new_bool: bool) -> void:
	emit_signal("cursor_is_enabled", new_bool)
