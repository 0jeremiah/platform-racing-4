extends Node2D
class_name EditorMenu

signal control_event
signal editor_event
signal cursor_is_enabled

@onready var level_options_menu = $LevelOptionsMenu
@onready var block_options_menu = $BlockOptionsMenu
var current_editor = null
var current_layers: Node2D
var editor_events: EditorEvents
var can_edit: bool = true


func _ready():
	get_viewport().size_changed.connect(_on_size_changed)
	level_options_menu.control_event.connect(_on_control_event)
	level_options_menu.editor_event.connect(_on_editor_event)
	level_options_menu.cursor_is_enabled.connect(_on_cursor_is_enabled.bind())
	block_options_menu.control_event.connect(_on_control_event)
	block_options_menu.editor_event.connect(_on_editor_event)
	block_options_menu.cursor_is_enabled.connect(_on_cursor_is_enabled.bind())
	_on_size_changed()


func init(new_current_layers: Node2D, new_editor_events: EditorEvents) -> void:
	current_layers = new_current_layers
	editor_events = new_editor_events
	if new_current_layers is LevelLayers:
		level_options_menu.init(current_layers, editor_events)
	if new_current_layers is BlockLayers:
		block_options_menu.init(current_layers, editor_events)


func set_editor_mode(new_current_editor):
	level_options_menu.visible = false
	block_options_menu.visible = false
	if new_current_editor is LevelEditor or new_current_editor is BlockEditor:
		current_editor = new_current_editor
		if current_editor is LevelEditor:
			level_options_menu.current_editor = current_editor
			level_options_menu.visible = true
		if current_editor is BlockEditor:
			block_options_menu.current_editor = current_editor
			block_options_menu.visible = true


func _on_size_changed():
	var window_size = get_viewport().get_visible_rect().size
	if window_size.x > 0 and window_size.y > 0:
		position = Vector2(0, 0)


func _on_control_event(event: Dictionary) -> void:
	print("EditorMenu::_on_control_event ", event)
	control_event.emit(event)
	

func _on_editor_event(event: Dictionary) -> void:
	print("EditorMenu::_on_editor_event ", event)
	editor_event.emit(event)


func _on_cursor_is_enabled(new_bool: bool) -> void:
	emit_signal("cursor_is_enabled", new_bool)
