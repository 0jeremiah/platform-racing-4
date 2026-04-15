extends Control

signal control_event
signal level_event
signal cursor_is_enabled

@onready var selection_glow = $SelectionGlow
@onready var button_list = $Buttons
@onready var block_menu_button = $Buttons/BlockMenuButton/TextureButton
@onready var art_menu_button = $Buttons/ArtMenuButton/TextureButton
@onready var level_settings_button = $Buttons/LevelSettingsButton/TextureButton
@onready var collab_button = $Buttons/CollabButton/TextureButton
@onready var level_settings_dropdown_button = $Buttons/ExtraOptionsButton/LevelSettingsDropdownButton
@onready var extra_options_button = $Buttons/ExtraOptionsButton/TextureButton
@onready var test_level_button = $Buttons/TestLevelButton/TextureButton
@onready var submenus = $Submenus
@onready var block_submenu = $Submenus/BlockSubmenu
@onready var art_submenu = $Submenus/ArtSubmenu
@onready var level_settings_submenu = $Submenus/LevelSettingsSubmenu
@onready var collab_submenu = $Submenus/CollabSubmenu
var current_submenu: Control
var level_layers: Node2D
var editor_events: EditorEvents
var current_editor = null
var selected_button: TextureButton
var old_selected_button: TextureButton
var settings_list: Dictionary = {
	"undo": {
		"setting_name": "Undo (CTRL + Z)",
		"use_seperator": false,
		},
	"redo": {
		"setting_name": "Redo (CTRL + Y)",
		"use_seperator": true,
		},
	"new": {
		"setting_name": "New",
		"setting_func": Callable(self, "_maybe_clear_level"),
		"use_seperator": false,
		},
	"load": {
		"setting_name": "Load",
		"setting_func": Callable(self, "_on_load_pressed"),
		"use_seperator": false,
		},
	"save": {
		"setting_name": "Save",
		"setting_func": Callable(self, "_on_save_pressed"),
		"use_seperator": true,
		},
	"import": {
		"setting_name": "Import",
		"use_seperator": false,
		},
	"export": {
		"setting_name": "Export",
		"use_seperator": true,
		},
	"gotoblockeditor": {
		"setting_name": "Goto Block Editor",
		"setting_func": Callable(self, "_goto_block_editor_page"),
		"use_seperator": false,
		},
	"gotootherpage": {
		"setting_name": "Lobby/MainMenu",
		"setting_func": Callable(self, "_goto_other_page"),
		"use_seperator": true,
		},
	"nevermind": {
		"setting_name": "Never Mind",
		"use_seperator": false,
		},
}


func _ready() -> void:
	block_menu_button.pressed.connect(_click_block_menu.bind(block_menu_button))
	art_menu_button.pressed.connect(_click_block_menu.bind(art_menu_button))
	level_settings_button.pressed.connect(_click_block_menu.bind(level_settings_button))
	collab_button.pressed.connect(_click_block_menu.bind(collab_button))
	var options_keys = settings_list.keys()
	var logged_in = Session.is_logged_in()
	for option in settings_list.size():
		var label = settings_list[options_keys[option]].setting_name
		if settings_list[options_keys[option]].setting_name == "Lobby/MainMenu":
			if logged_in:
				label = "Goto Lobby"
			else:
				label = "Goto Main Menu"
		level_settings_dropdown_button.get_popup().add_item(label, option)
		if settings_list[options_keys[option]].has("use_seperator") and settings_list[options_keys[option]].use_seperator:
			level_settings_dropdown_button.get_popup().add_separator()
	level_settings_dropdown_button.get_popup().id_pressed.connect(_call_editor_function)
	test_level_button.pressed.connect(_on_test_pressed)
	selected_button = block_menu_button
	set_submenu()


func init(new_level_layers: Node2D, new_editor_events: EditorEvents) -> void:
	level_layers = new_level_layers
	editor_events = new_editor_events
	for child in submenus.get_children():
		if "control_event" in child:
			child.control_event.connect(_on_control_event)
		if "level_event" in child:
			child.level_event.connect(_on_level_event)
		if "current_layers" in child or "editor_events" in child or "current_editor" in child:
			if "current_layers" in child:
				child.current_layers = level_layers
			if "editor_events" in child:
				child.editor_events = editor_events
			if "current_editor" in child:
				child.current_editor = current_editor
			child.init()


func _process(_delta: float) -> void:
	for child in button_list.get_children():
		for node in child.get_children():
			if node is TextureButton or node is MenuButton:
				if node.is_hovered() and !node.is_pressed():
					node.get_parent().scale = Vector2(1.25, 1.25)
				else:
					node.get_parent().scale = Vector2(1, 1)
				if selected_button.get_parent() == node.get_parent():
					node.self_modulate = Color("ffffff")
				else:
					node.self_modulate = Color("2a9fd6")
			elif node is ColorRect:
				if selected_button.get_parent() == node.get_parent():
					node.self_modulate = Color("2a9fd6")
				else:
					node.self_modulate = Color("ffffff")
					
	if old_selected_button != selected_button:
		set_submenu()
		old_selected_button = selected_button
	set_selection_glow()


func set_submenu():
	if current_submenu:
		current_submenu.deactivate()
	if selected_button == block_menu_button:
		current_submenu = block_submenu
		emit_signal("cursor_is_enabled", true)
	elif selected_button == art_menu_button:
		current_submenu = art_submenu
		emit_signal("cursor_is_enabled", true)
	elif selected_button == level_settings_button:
		current_submenu = level_settings_submenu
		emit_signal("cursor_is_enabled", false)
	elif selected_button == collab_button:
		current_submenu = collab_submenu
		emit_signal("cursor_is_enabled", false)
	current_submenu.activate()


func _on_control_event(event: Dictionary) -> void:
	print("LevelOptionsMenu::_on_control_event ", event)
	control_event.emit(event)


func _on_level_event(event: Dictionary) -> void:
	print("LevelOptionsMenu::_on_level_event ", event)
	level_event.emit(event)


func _click_block_menu(button: TextureButton):
	selected_button = button


func _on_test_pressed():
	current_editor._on_test_pressed()


func set_selection_glow():
	selection_glow.size = (selected_button.get_parent().size * selected_button.get_parent().scale) + Vector2(10, 10)
	selection_glow.global_position = selected_button.get_parent().global_position - Vector2(5, 5)


func _call_editor_function(id: int):
	var options_keys = settings_list.keys()
	if settings_list[options_keys[id]].has("setting_func"):
		settings_list[options_keys[id]].setting_func.call()


func _maybe_clear_level():
	current_editor._on_clear_pressed()


func _on_load_pressed():
	current_editor._on_load_pressed()


func _on_save_pressed():
	current_editor._on_save_pressed()


func _goto_block_editor_page():
	current_editor._on_block_editor_pressed()


func _goto_other_page():
	current_editor._on_back_pressed()
