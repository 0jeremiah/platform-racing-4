extends Node2D
class_name Cursor

signal editor_event

var active = false
var touching_gui = false
var using_gui = false
var mouse_down = false
var old_cursor: String
var current_cursor: Node2D
var editor_menu: EditorMenu

@onready var control = $Control
@onready var block_cursor = $BlockCursor
@onready var draw_cursor = $DrawCursor
@onready var stamp_cursor = $StampCursor
@onready var text_cursor = $TextCursor
@onready var cursor_icon = $CursorIcon
@onready var cursor_colorin = $CursorIcon/CursorColorIn
@onready var cursor_outline = $CursorIcon/CursorOutline


func _ready():
	#Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	cursor_colorin.self_modulate = Color(randf_range(0, 1), randf_range(0, 1), randf_range(0, 1))
	cursor_outline.self_modulate = Color(randf_range(0, 1), randf_range(0, 1), randf_range(0, 1))
	cursor_icon.visible = false


func deactivate():
	if current_cursor:
		current_cursor.deactivate()
	active = false


func activate():
	if current_cursor:
		current_cursor.activate()
	active = true
	global_position = get_global_mouse_position()


func _exit_tree() -> void:
	#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	pass


func init(_editor_menu, layers) -> void:
	print("Cursor::init")
	editor_menu = _editor_menu
	if "current_editor" in _editor_menu and "object_box" in _editor_menu.current_editor:
		_editor_menu.current_editor.object_box.object_moved.connect(_object_moved)
		_editor_menu.current_editor.object_box.object_deleted.connect(_object_deleted)
		_editor_menu.current_editor.object_box.object_resized.connect(_object_resized)
		_editor_menu.current_editor.object_box.object_text_edited.connect(_object_text_edited)
		_editor_menu.current_editor.object_box.object_options_changed.connect(_object_options_changed )
	
	block_cursor.init(layers, self)
	draw_cursor.init(layers, self)
	stamp_cursor.init(layers, self)
	text_cursor.init(layers, self)
	
	editor_menu.control_event.connect(_on_control_event)
	control.gui_input.connect(_on_gui_input)
	control.mouse_entered.connect(_on_mouse_entered)
	control.mouse_exited.connect(_on_mouse_exited)
	
	for child in get_children():
		if child.has_signal("editor_event"):
			child.editor_event.connect(_on_subcursor_event)


func _on_gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		using_gui = false


func _on_mouse_entered():
	touching_gui = true


func _on_mouse_exited():
	touching_gui = false


func _physics_process(_delta):
	if active:
		visible = true
		global_position = get_global_mouse_position()
		if current_cursor != null and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) && !using_gui: # Left click
			if !mouse_down:
				current_cursor.on_mouse_down()
				mouse_down = true
			current_cursor.on_drag()
		else:
			if mouse_down:
				current_cursor.on_mouse_up()
				mouse_down = false
			using_gui = true
	else:
		visible = false


# block_id = event.block_id

func _on_control_event(event: Dictionary) -> void:
	if active:
		if event.type == EditorEvents.SELECT_BLOCK:
			if current_cursor:
				current_cursor.deactivate()
			current_cursor = block_cursor
			current_cursor.activate()
		elif event.type == EditorEvents.SELECT_TOOL:
			$Control.mouse_filter = 0
			if current_cursor:
				current_cursor.deactivate()
			if event.tool == "blocks":
				current_cursor = block_cursor
			elif event.tool == "draw" or event.tool == "erase":
				current_cursor = draw_cursor
			elif event.tool == "stamp":
				current_cursor = stamp_cursor
			elif event.tool == "text":
				current_cursor = text_cursor
				$Control.mouse_filter = 1
			current_cursor.activate()
		elif event.type == EditorEvents.SELECT_DRAW_SIZE and current_cursor == draw_cursor:
			draw_cursor.set_draw_size(event.size)
		elif event.type == EditorEvents.SELECT_DRAW_COLOR and current_cursor == draw_cursor:
				# Convert hex string to Color object
				draw_cursor.set_draw_color(event.color)
		elif event.type == EditorEvents.SELECT_DRAW_ALPHA and current_cursor == draw_cursor:
				# Convert hex string to Color object
				draw_cursor.set_draw_alpha(event.alpha)
		elif event.type == EditorEvents.SELECT_ERASE_SIZE and current_cursor == draw_cursor:
				draw_cursor.set_erase_size(event.size)
		elif event.type == EditorEvents.SELECT_ERASE_ALPHA and current_cursor == draw_cursor:
				# Convert hex string to Color object
				draw_cursor.set_erase_alpha(event.alpha)
		elif event.type == EditorEvents.SELECT_STAMP and current_cursor == stamp_cursor:
				stamp_cursor.set_stamp_id(event.stamp)
		elif event.type == EditorEvents.SELECT_STAMP_SIZE and current_cursor == stamp_cursor:
				stamp_cursor.set_stamp_size(event.size)
		elif event.type == EditorEvents.SELECT_STAMP_ROTATION and current_cursor == stamp_cursor:
				stamp_cursor.set_stamp_rotation(event.rotation)
		elif event.type == EditorEvents.SELECT_STAMP_MODE and current_cursor == stamp_cursor:
				stamp_cursor.set_stamp_mode(event.mode)
		elif event.type == EditorEvents.SELECT_TEXT_SIZE and current_cursor == text_cursor:
				text_cursor.set_text_font_size(event.size)
		elif event.type == EditorEvents.SELECT_TEXT_COLOR and current_cursor == text_cursor:
				text_cursor.set_text_color(event.color)
		elif event.type == EditorEvents.SELECT_TEXT_ROTATION and current_cursor == text_cursor:
				text_cursor.set_text_rotation(event.rotation)
		elif event.type == EditorEvents.SELECT_TEXT_FONT and current_cursor == text_cursor:
				text_cursor.set_text_font(event.font)


func _on_subcursor_event(event: Dictionary) -> void:
	editor_event.emit(event)


func _object_moved(object_info: Dictionary):
	if current_cursor != null and current_cursor.has_method("_object_moved"):
		current_cursor._object_moved(object_info)


func _object_deleted(object_info: Dictionary):
	if current_cursor != null and current_cursor.has_method("_object_deleted"):
		current_cursor._object_deleted(object_info)


func _object_resized(object_info: Dictionary):
	if current_cursor != null and current_cursor.has_method("_object_resized"):
		current_cursor._object_resized(object_info)


func _object_text_edited(object_info: Dictionary):
	if current_cursor != null and current_cursor.has_method("_object_text_edited"):
		current_cursor._object_text_edited(object_info)


func _object_options_changed(object_info: Dictionary):
	if current_cursor != null and current_cursor.has_method("_object_options_changed"):
		current_cursor._object_options_changed(object_info)
