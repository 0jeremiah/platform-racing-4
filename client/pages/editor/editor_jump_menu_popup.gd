extends ButtonPopup

@onready var jump_menu = preload("res://ui/jump_menu/jump_menu.tscn")

var jump_menu_node = null
var mode = ""
var current_editor = null


func _ready() -> void:
	super()
	set_intrusive(false)
	set_auto_position(false)
	set_die_without_focus(true)
	jump_menu_node = jump_menu.instantiate()
	add_node_to_holder(jump_menu_node)
	jump_menu_node.jump_menu_option_chosen.connect(_call_jump_menu_func)


func init(init_params: Dictionary):
	if "current_editor" in init_params:
		current_editor = init_params.current_editor
		if current_editor.has_method("_on_undo_pressed"):
			jump_menu_node.create_button("Undo (Ctrl-Z)", Callable(current_editor, "_on_undo_pressed"))
		if current_editor.has_method("_on_redo_pressed"):
			jump_menu_node.create_button("Redo (Ctrl-Y)", Callable(current_editor, "_on_redo_pressed"))
		jump_menu_node.create_separator()
		if current_editor.has_method("_on_clear_pressed"):
			jump_menu_node.create_button("Clear", Callable(current_editor, "_on_clear_pressed"))
		if current_editor.has_method("_on_load_pressed"):
			jump_menu_node.create_button("Load from account", Callable(current_editor, "_on_load_pressed"))
		if current_editor.has_method("_on_save_pressed"):
			jump_menu_node.create_button("Save to account", Callable(current_editor, "_on_save_pressed"))
		jump_menu_node.create_separator()
		if current_editor.has_method("_on_import_pressed"):
			jump_menu_node.create_button("Load from disk", Callable(current_editor, "_on_import_pressed"))
		if current_editor.has_method("_on_export_pressed"):
			jump_menu_node.create_button("Save to disk", Callable(current_editor, "_on_export_pressed"))
		jump_menu_node.create_separator()
		if !(current_editor is LevelEditor) and current_editor.has_method("_on_level_editor_pressed"):
			jump_menu_node.create_button("Goto Level Editor", Callable(current_editor, "_on_level_editor_pressed"))
		if !(current_editor is BlockEditor) and current_editor.has_method("_on_block_editor_pressed"):
			jump_menu_node.create_button("Goto Block Editor", Callable(current_editor, "_on_block_editor_pressed"))
		if current_editor.has_method("_on_back_pressed"):
			var page_text = "Main Menu"
			if Session.is_logged_in():
				page_text = "Lobby"
			jump_menu_node.create_button("Goto " + page_text, Callable(current_editor, "_on_back_pressed"))
	if "popup_position" in init_params:
		popup.position = init_params.popup_position


func _call_jump_menu_func(jump_menu_func = null):
	if jump_menu_func is Callable:
		jump_menu_func.call()
	queue_free()
