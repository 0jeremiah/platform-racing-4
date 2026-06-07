extends Control

signal editor_event
signal control_event

const LAYER_ROW = preload("res://engine/layer_panel/layer_row.tscn")

@onready var new_button = $NewButton
@onready var move_up_button = $MoveUpButton
@onready var move_down_button = $MoveDownButton
@onready var set_anchor_button = $SetAnchorButton
@onready var delete_button = $DeleteButton
@onready var row_holder = $RowContainer/RowHolder
@onready var light_settings_color_rect = $LightSettingsColorRect
@onready var dark_settings_color_rect = $DarkSettingsColorRect
@onready var settings_tab = $SettingsTab
@onready var layer_settings_container = $LayerSettingsContainer
@onready var z_axis_box = $LayerSettingsContainer/LayerSettings/ZAxisContainer/ZAxisBox
@onready var depth_box = $LayerSettingsContainer/LayerSettings/DepthContainer/DepthBox
@onready var rotation_box = $LayerSettingsContainer/LayerSettings/RotationContainer/RotationBox
@onready var alpha_box = $LayerSettingsContainer/LayerSettings/AlphaContainer/AlphaBox
@onready var anchor_x_box = $LayerSettingsContainer/LayerSettings/AnchorContainer/AnchorXBox
@onready var anchor_y_box = $LayerSettingsContainer/LayerSettings/AnchorContainer/AnchorYBox
@onready var block_effect_settings_container = $BlockEffectSettingsContainer
@onready var block_effect_settings = $BlockEffectSettingsContainer/BlockEffectSettings
@onready var rename_layer_popup = $RenameLayerPopup

var active: bool = false
var current_layers: Node2D
var current_editor = null
var show_layer_type: String = "blocks"
var block_effects = {"teleport_color": false, "up_arrow": false, "left_arrow": false, "down_arrow": false,
"right_arrow": false, "move_up": false, "move_left": false, "move_right": false, "move_down": false}


func _ready():
	new_button.pressed.connect(_new_pressed)
	move_up_button.pressed.connect(_move_up_layer)
	move_down_button.pressed.connect(_move_down_layer)
	delete_button.pressed.connect(_delete_pressed)
	settings_tab.tab_changed.connect(_change_tab)
	var block_effects_keys = block_effects.keys()
	for child in block_effect_settings.get_child_count():
		if block_effect_settings.get_child(child) is CheckBox:
			block_effect_settings.get_child(child).pressed.connect(_maybe_enable_block_effect.bind(child, block_effects_keys[child]))
	rename_layer_popup.name_change.connect(_set_layer_name)


func init(new_current_editor, new_layers: Node2D, new_show_layer_type: String) -> void:
	current_editor = new_current_editor
	current_layers = new_layers
	show_layer_type = new_show_layer_type
	if current_editor is LevelEditor:
		depth_box.init("int", "120", 0, 50)
		depth_box.return_line.connect(_depth_change)
		if show_layer_type == "art":
			z_axis_box.init("int", "10", 0, 50)
			z_axis_box.return_line.connect(_z_axis_change)
		else:
			z_axis_box.init("int", "10", 0, 16)
			z_axis_box.return_line.connect(_z_axis_change)
	elif current_editor is BlockEditor:
		var block_effects_keys = block_effects.keys()
		for child in block_effect_settings.get_child_count():
			if block_effect_settings.get_child(child) is CheckBox:
				block_effect_settings.get_child(child).pressed.connect(_maybe_enable_block_effect.bind(child, block_effects_keys[child]))
	if current_layers:
		current_layers.layers_changed.connect(render)
		current_layers.layers_loaded.connect(render)
	rotation_box.init("int", "0", 0, 359)
	rotation_box.return_line.connect(_rotation_change)
	alpha_box.init("int", "0", 0, 100)
	alpha_box.return_line.connect(_alpha_change)
	anchor_x_box.init("float", "0.0", -9999999.9, 99999999.9)
	anchor_x_box.return_line.connect(_anchor_x_change)
	anchor_y_box.init("float", "0.0", -9999999.9, 99999999.9)
	anchor_y_box.return_line.connect(_anchor_y_change)


func render() -> void:
	clear()
	new_button.disabled = true
	move_up_button.disabled = true
	move_down_button.disabled = true
	set_anchor_button.disabled = true
	delete_button.disabled = true
	var alpha_render = true
	var layer_array = []
	var target_layer = ""
	if current_editor.editor_menu.can_edit and show_layer_type == "blocks":
		layer_array = current_layers.map_layers.get_children()
		layer_array.reverse()
		target_layer = current_layers.get_target_map_layer()
		new_button.disabled = false
		if current_layers.map_layers.get_child_count() > 1 and current_layers.map_layers.get_node(target_layer).get_index() > 0:
			move_down_button.disabled = false
		if current_layers.map_layers.get_child_count() > 1 and current_layers.map_layers.get_node(target_layer).get_index() < current_layers.map_layers.get_child_count() - 1:
			move_up_button.disabled = false
		if current_layers.map_layers.get_child_count() > 1:
			delete_button.disabled = false
	elif current_editor.editor_menu.can_edit and show_layer_type == "art":
		layer_array = current_layers.art_layers.get_children()
		layer_array.reverse()
		target_layer = current_layers.get_target_art_layer()
		new_button.disabled = false
		if current_layers.art_layers.get_child_count() > 1 and current_layers.art_layers.get_node(target_layer).get_index() > 0:
			move_down_button.disabled = false
		if current_layers.art_layers.get_child_count() > 1 and current_layers.art_layers.get_node(target_layer).get_index() < current_layers.art_layers.get_child_count() - 1:
			move_up_button.disabled = false
		if current_layers.art_layers.get_child_count() > 1:
			delete_button.disabled = false
	var i: int = 0
	for layer in layer_array:
		if not (layer is MapLayer or layer is ArtLayer):
			continue
		i += 1
		var row = LAYER_ROW.instantiate()
		row.name = "LayerRow" + str(i)
		row.get_node("LayerNameButton").text = layer.layer_name
		row_holder.add_child(row)
		
		var layer_button = row.get_node("LayerNameButton")
		if current_editor.editor_menu.can_edit:
			layer_button.modulate.a = 1.0
			layer_button.pressed.connect(_row_pressed.bind(layer.name, layer_button))
			if target_layer == layer.name:
				layer_button.button_pressed = true
		else:
			layer_button.modulate.a = 0.5
	if alpha_render:
		render_layers(show_layer_type)
	update_boxes()


func render_layers(_show_layer_type: String):
	var visible_layer_array = []
	var visible_target_layer = ""
	if "map_layers" in current_layers:
		visible_layer_array = current_layers.map_layers.get_children()
		visible_target_layer = current_layers.get_target_map_layer()
		for visible_layer in visible_layer_array:
			visible_layer.modulate.a = 0.5
			if show_layer_type == "blocks" and visible_target_layer == visible_layer.name:
				visible_layer.modulate.a = 1.0
	if "art_layers" in current_layers:
		visible_layer_array = current_layers.art_layers.get_children()
		visible_target_layer = current_layers.get_target_art_layer()
		for visible_layer in visible_layer_array:
			visible_layer.modulate.a = 0.5
			if show_layer_type == "art" and visible_target_layer == visible_layer.name:
				visible_layer.modulate.a = 1.0


func disable_box(box: LineEdit):
	box.editable = false
	box.selecting_enabled = false
	box.focus_mode = Control.FOCUS_NONE


func enable_box(box: LineEdit):
	box.editable = true
	box.selecting_enabled = true
	box.focus_mode = Control.FOCUS_CLICK


func update_boxes() -> void:
	var layer = null
	disable_box(z_axis_box)
	disable_box(depth_box)
	disable_box(rotation_box)
	disable_box(alpha_box)
	disable_box(anchor_x_box)
	disable_box(anchor_y_box)
	settings_tab.visible = false
	for tab in settings_tab.tab_count:
		settings_tab.set_tab_disabled(tab, true)
	for child in block_effect_settings.get_child_count():
		if block_effect_settings.get_child(child) is CheckBox:
			block_effect_settings.get_child(child).disabled = true
	light_settings_color_rect.size.y = 125.0
	light_settings_color_rect.position.y = settings_tab.position.y
	if current_editor.editor_menu.can_edit:
		if show_layer_type == "blocks":
			layer = current_layers.map_layers.get_node(current_layers.get_target_map_layer())
		elif show_layer_type == "art":
			layer = current_layers.art_layers.get_node(current_layers.get_target_art_layer())
		if layer is MapLayer:
			enable_box(z_axis_box)
			z_axis_box._update_text(str(layer.z_axis))
			depth_box._update_text("10")
			enable_box(rotation_box)
			rotation_box._update_text(str(layer.tile_map_rotation))
			alpha_box._update_text("100")
			enable_box(anchor_x_box)
			anchor_x_box._update_text(str(layer.anchor.x))
			enable_box(anchor_y_box)
			anchor_y_box._update_text(str(layer.anchor.y))
		if layer is ArtLayer:
			if current_editor is LevelEditor:
				enable_box(z_axis_box)
				z_axis_box._update_text(str(layer.z_axis))
				enable_box(depth_box)
				depth_box._update_text(str(layer.depth))
			elif current_editor is BlockEditor:
				for tab in settings_tab.tab_count:
					settings_tab.set_tab_disabled(tab, false)
				settings_tab.visible = true
				light_settings_color_rect.size.y -= settings_tab.size.y + 5
				light_settings_color_rect.position.y += settings_tab.size.y + 5
				for child in block_effect_settings.get_child_count():
					if block_effect_settings.get_child(child) is CheckBox:
						block_effect_settings.get_child(child).disabled = false
						block_effect_settings.get_child(child).set_pressed_no_signal(false)
				var block_effects_keys = block_effects.keys()
				for child in block_effect_settings.get_child_count():
					if block_effects_keys[child] in layer.block_effect_settings and layer.block_effect_settings[block_effects_keys[child]] == true:
						block_effect_settings.get_child(child).set_pressed_no_signal(true)
			enable_box(rotation_box)
			rotation_box._update_text(str(round(layer.art_rotation)))
			enable_box(alpha_box)
			alpha_box._update_text(str(layer.alpha))
			enable_box(anchor_x_box)
			anchor_x_box._update_text(str(layer.anchor.x))
			enable_box(anchor_y_box)
			anchor_y_box._update_text(str(layer.anchor.y))
	elif current_editor is BlockEditor:
		settings_tab.visible = true
		light_settings_color_rect.size.y -= settings_tab.size.y + 5
		light_settings_color_rect.position.y += settings_tab.size.y + 5
	dark_settings_color_rect.size.y = light_settings_color_rect.size.y - 10
	dark_settings_color_rect.position.y = light_settings_color_rect.position.y + 5
	layer_settings_container.size.y = dark_settings_color_rect.size.y
	layer_settings_container.position.y = dark_settings_color_rect.position.y
	block_effect_settings_container.size.y = dark_settings_color_rect.size.y
	block_effect_settings_container.position.y = dark_settings_color_rect.position.y


func _change_tab(new_index: int):
	layer_settings_container.visible = false
	block_effect_settings_container.visible = false
	if new_index == 1:
		block_effect_settings_container.visible = true
	else:
		layer_settings_container.visible = true


func clear() -> void:
	for child in row_holder.get_children():
		child.free()


func _new_pressed():
	if show_layer_type == "blocks":
		var i = current_layers.map_layers.get_child_count() + 1
		var new_name = "Layer " + str(i)
		while(current_layers.map_layers.get_node(new_name)):
			i += 1
			new_name = "Layer " + str(i)
		emit_signal("editor_event", {
			"type": EditorEvents.ADD_MAP_LAYER,
			"name": new_name
		})
		current_layers.set_target_map_layer(new_name)
	elif show_layer_type == "art":
		var i = current_layers.art_layers.get_child_count() + 1
		var new_name = "Layer " + str(i)
		while(current_layers.art_layers.get_node(new_name)):
			i += 1
			new_name = "Layer " + str(i)
		emit_signal("editor_event", {
			"type": EditorEvents.ADD_ART_LAYER,
			"name": new_name
		})
		current_layers.set_target_art_layer(new_name)


func _delete_pressed():
	if show_layer_type == "blocks":
		emit_signal("editor_event", {
			"type": EditorEvents.DELETE_MAP_LAYER,
			"name": current_layers.get_target_map_layer()
		})
	elif show_layer_type == "art":
		emit_signal("editor_event", {
			"type": EditorEvents.DELETE_ART_LAYER,
			"name": current_layers.get_target_art_layer()
		})


func _move_up_layer():
	if show_layer_type == "blocks":
		var layer = current_layers.map_layers.get_node(current_layers.get_target_map_layer())
		if layer.get_index() < current_layers.map_layers.get_child_count() - 1:
			current_layers.map_layers.move_child(layer, layer.get_index() + 1)
			render()
	elif show_layer_type == "art":
		var layer = current_layers.art_layers.get_node(current_layers.get_target_art_layer())
		if layer.get_index() < current_layers.art_layers.get_child_count() - 1:
			current_layers.art_layers.move_child(layer, layer.get_index() + 1)
			render()


func _move_down_layer():
	if show_layer_type == "blocks":
		var layer = current_layers.map_layers.get_node(current_layers.get_target_map_layer())
		if layer.get_index() > 0:
			current_layers.map_layers.move_child(layer, layer.get_index() - 1)
			render()
	elif show_layer_type == "art":
		var layer = current_layers.art_layers.get_node(current_layers.get_target_art_layer())
		if layer.get_index() > 0:
			current_layers.art_layers.move_child(layer, layer.get_index() - 1)
			render()


func _row_pressed(layer_name: String, layer_button: Button):
	if show_layer_type == "blocks":
		if current_layers.get_target_map_layer() == layer_name:
			var layer = current_layers.map_layers.get_node(current_layers.get_target_map_layer())
			rename_layer_popup.new_layer_name.text = layer.layer_name
			rename_layer_popup.popup(Rect2(layer_button.global_position.x, layer_button.global_position.y, 288.0, 40.0))
		else:
			current_layers.set_target_map_layer(layer_name)
			emit_signal("control_event", {
				"type": EditorEvents.SELECT_MAP_LAYER,
				"layer_name": layer_name
			})
			call_deferred("render")
	elif show_layer_type == "art":
		if current_layers.get_target_art_layer() == layer_name:
			var layer = current_layers.art_layers.get_node(current_layers.get_target_art_layer())
			rename_layer_popup.new_layer_name.text = layer.layer_name
			rename_layer_popup.popup(Rect2(layer_button.global_position.x, layer_button.global_position.y, 288.0, 40.0))
		else:
			current_layers.set_target_art_layer(layer_name)
			emit_signal("control_event", {
				"type": EditorEvents.SELECT_ART_LAYER,
				"layer_name": layer_name
			})
			call_deferred("render")


func _z_axis_change(new_z_axis: int):
	if show_layer_type == "blocks" and new_z_axis != current_layers.map_layers.get_node(current_layers.get_target_map_layer()).z_axis:
		emit_signal("editor_event", {
			"type": EditorEvents.SET_MAP_LAYER_Z_AXIS,
			"layer_name": current_layers.get_target_map_layer(),
			"z_axis": new_z_axis
		})
	elif show_layer_type == "art" and new_z_axis != current_layers.art_layers.get_node(current_layers.get_target_art_layer()).z_axis:
		emit_signal("editor_event", {
			"type": EditorEvents.SET_ART_LAYER_Z_AXIS,
			"layer_name": current_layers.get_target_art_layer(),
			"z_axis": new_z_axis
		})


func _depth_change(new_depth: int):
	if show_layer_type == "art" and new_depth != current_layers.art_layers.get_node(current_layers.get_target_art_layer()).depth:
		emit_signal("editor_event", {
			"type": EditorEvents.SET_ART_LAYER_DEPTH,
			"layer_name": current_layers.get_target_art_layer(),
			"depth": new_depth
		})


func _rotation_change(new_rotation: int):
	if show_layer_type == "blocks" and new_rotation != current_layers.map_layers.get_node(current_layers.get_target_map_layer()).tile_map_rotation:
		emit_signal("editor_event", {
			"type": EditorEvents.SET_MAP_LAYER_ROTATION,
			"layer_name": current_layers.get_target_map_layer(),
			"rotation": new_rotation
		})
	elif show_layer_type == "art" and new_rotation != current_layers.art_layers.get_node(current_layers.get_target_art_layer()).art_rotation:
		emit_signal("editor_event", {
			"type": EditorEvents.SET_ART_LAYER_ROTATION,
			"layer_name": current_layers.get_target_art_layer(),
			"rotation": int(new_rotation)
		})


func _alpha_change(new_alpha: int):
	if show_layer_type == "art" and new_alpha != current_layers.art_layers.get_node(current_layers.get_target_art_layer()).alpha:
		emit_signal("editor_event", {
			"type": EditorEvents.SET_ART_LAYER_ALPHA,
			"layer_name": current_layers.get_target_art_layer(),
			"alpha": new_alpha
		})


func _anchor_x_change(new_anchor_x: float):
	_anchor_change(Vector2(new_anchor_x, float(anchor_y_box.text)))


func _anchor_y_change(new_anchor_y: float):
	_anchor_change(Vector2(float(anchor_x_box.text), new_anchor_y))


func _anchor_change(new_anchor: Vector2):
	if show_layer_type == "blocks" and new_anchor != current_layers.map_layers.get_node(current_layers.get_target_map_layer()).anchor:
		emit_signal("editor_event", {
			"type": EditorEvents.SET_MAP_LAYER_ANCHOR,
			"layer_name": current_layers.get_target_map_layer(),
			"anchor": {"x": new_anchor.x, "y": new_anchor.y}
		})
	elif show_layer_type == "art" and new_anchor != current_layers.art_layers.get_node(current_layers.get_target_art_layer()).anchor:
		emit_signal("editor_event", {
			"type": EditorEvents.SET_ART_LAYER_ANCHOR,
			"layer_name": current_layers.get_target_art_layer(),
			"anchor": {"x": new_anchor.x, "y": new_anchor.y}
		})


func _set_layer_name(new_layer_name: String):
	if show_layer_type == "blocks" and current_layers.map_layers.get_node(current_layers.get_target_map_layer()).layer_name != new_layer_name:
		emit_signal("editor_event", {
			"type": EditorEvents.RENAME_MAP_LAYER,
			"layer_name": current_layers.get_target_map_layer(),
			"new_layer_name": new_layer_name
		})
		rename_layer_popup.hide()
		render()
	elif show_layer_type == "art" and current_layers.art_layers.get_node(current_layers.get_target_art_layer()).layer_name != new_layer_name:
		emit_signal("editor_event", {
			"type": EditorEvents.RENAME_ART_LAYER,
			"layer_name": current_layers.get_target_art_layer(),
			"new_layer_name": new_layer_name
		})
		rename_layer_popup.hide()
		render()


func _maybe_enable_block_effect(button_index: int, block_effect_key: String):
	if block_effect_settings.get_child(button_index).button_pressed:
		block_effects[block_effect_key] = true
	else:
		block_effects[block_effect_key] = false
	var block_effects_keys = block_effects.keys()
	var enabled_block_effects = {}
	for key in block_effects_keys:
		if block_effects[key] == true:
			enabled_block_effects.get_or_add(key, block_effects[key])
	emit_signal("editor_event", {
		"type": EditorEvents.SET_ART_LAYER_BLOCK_EFFECTS,
		"layer_name": current_layers.get_target_art_layer(),
		"block_effect_settings": enabled_block_effects
	})
