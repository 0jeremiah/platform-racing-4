extends Control

@onready var config_tab_bar = $ConfigTabBar
@onready var settings_container = $ScrollContainer/SettingsContainer
@onready var editbox = preload("res://ui/game_config_editbox.gd")

var settings_nodes: Dictionary = {}


func _ready() -> void:
	config_tab_bar.tab_changed.connect(_populate_options.bind())
	_populate_options(config_tab_bar.current_tab)


func _populate_options(key_number: int):
	for child in settings_container.get_children():
		child.free()
	var keys = GameConfig.default_values.keys()
	for key in GameConfig.default_values.get(keys[key_number]):
		var example_control = Control.new()
		var example_label = RichTextLabel.new()
		example_control.name = key.capitalize().replace(" ", "") + "Setting"
		example_label.fit_content = true
		example_label.autowrap_mode = 0
		example_label.vertical_alignment = 1
		example_label.size.y = 40
		example_label.set("theme_override_colors/default_color", Color("FFFFFFFF"))
		example_label.set("theme_override_colors/font_shadow_color", Color("0000007F"))
		example_label.text = key.capitalize() + ":"
		var label_size = example_label.get_theme_font("normal_font").get_string_size(example_label.text, HORIZONTAL_ALIGNMENT_LEFT, -1, example_label.get_theme_font_size("normal_font_size"))
		example_label.position = Vector2(0, 10)
		example_label.focus_mode = 0
		example_label.name = key.capitalize().replace(" ", "") + "Label"
		example_control.add_child(example_label)
		var example_edit = LineEdit.new()
		example_edit.set_script(editbox)
		example_edit.category_key = keys[key_number]
		example_edit.value_key = key
		var edit_value = GameConfig.get_value(keys[key_number], key)
		if edit_value is float:
			example_edit.init("float", str(edit_value))
		elif edit_value is int:
			example_edit.init("int", str(edit_value))
		else:
			example_edit.init("string", str(edit_value))
		# for some reason this doesn't emit the _on_text_changed signal???
		example_edit.return_data.connect(_on_text_changed)
		example_edit.max_length = 10
		example_edit.size = Vector2(150, 40)
		example_edit.position = Vector2(label_size.x + 10, 10)
		example_edit.focus_mode = 1
		example_edit.name = key.capitalize().replace(" ", "") + "Edit"
		example_control.add_child(example_edit)
		example_edit.text = str(GameConfig.get_value(keys[key_number], key))
		var reset_button = Button.new()
		reset_button.text = "Reset"
		reset_button.size = Vector2(100, 40)
		reset_button.position = Vector2(example_edit.size.x + example_edit.position.x + 10, 10)
		reset_button.focus_mode = 0
		reset_button.name = "ResetButton"
		reset_button.pressed.connect(_reset_value.bind([str(GameConfig.get_default_value(keys[key_number], key)), keys[key_number], key]))
		example_control.add_child(reset_button)
		example_control.size = Vector2(reset_button.size.x + reset_button.position.x, example_edit.size.y + 20)
		example_control.custom_minimum_size = example_control.size
		settings_container.add_child(example_control)
		settings_nodes[key] = example_edit


func _reset_value(data: Array):
	settings_nodes[data[2]].text = data[0]
	_on_text_changed(data)


func _on_text_changed(data: Array):
	var default_value = GameConfig.default_values.get(data[1])[data[2]]
	var new_value
	var category_key = data[1]
	var value_key = data[2]
	var category_override = GameConfig.override_values.get(category_key)


	if data[0].is_empty():
		if category_override != null and GameConfig.override_values.has(category_key):
			GameConfig.override_values.erase(category_key)
		return

	if default_value is float:
		new_value = data[0].to_float()
	elif default_value is int:
		new_value = data[0].to_int()
	else:
		new_value = data[0]
	
	if new_value == default_value:
		if category_override != null and GameConfig.override_values.has(category_key):
			GameConfig.override_values.erase(category_key)
	elif category_override != null and GameConfig.override_values.has(category_key):
		GameConfig.override_values.get(category_key)[value_key] = new_value
	else:
		GameConfig.override_values.get_or_add(category_key, {value_key: new_value})
