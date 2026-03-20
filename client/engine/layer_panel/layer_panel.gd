extends Control

signal level_event
signal control_event

const LAYER_ROW = preload("res://engine/layer_panel/layer_row.tscn")

var current_layers: Node2D
var show_layer_type: String = "blocks"
@onready var row_holder = $ScrollContainer/RowHolder
@onready var new_button = $NewButton
@onready var move_up_button = $MoveUpButton
@onready var move_down_button = $MoveDownButton
@onready var delete_button = $DeleteButton
@onready var z_axis_container = $ZAxisContainer
@onready var depth_container = $DepthContainer
@onready var rotation_container = $RotationContainer
@onready var alpha_container = $AlphaContainer
@onready var z_axis_box = $ZAxisContainer/ZAxisBox
@onready var depth_box = $DepthContainer/DepthBox
@onready var rotation_box = $RotationContainer/RotationBox
@onready var alpha_box = $AlphaContainer/AlphaBox
@onready var rename_layer_popup = $RenameLayerPopup

func _ready():
	new_button.pressed.connect(_new_pressed)
	move_up_button.pressed.connect(_move_up_layer)
	move_down_button.pressed.connect(_move_down_layer)
	delete_button.pressed.connect(_delete_pressed)
	
	rename_layer_popup.name_change.connect(_set_layer_name)


func init(new_layers: Node2D, new_show_layer_type: String) -> void:
	current_layers = new_layers
	show_layer_type = new_show_layer_type
	depth_box.init("int", "120", 0, 50)
	depth_box.return_line.connect(_depth_change)
	if show_layer_type == "art":
		z_axis_box.init("int", "10", 0, 50)
		z_axis_box.return_line.connect(_z_axis_change)
	else:
		z_axis_box.init("int", "10", 0, 16)
		z_axis_box.return_line.connect(_z_axis_change)
	rotation_box.init("int", "0", 0, 359)
	rotation_box.return_line.connect(_rotation_change)
	alpha_box.init("int", "0", 0, 100)
	alpha_box.return_line.connect(_alpha_change)
	render()


func render() -> void:
	clear()
	var layer_array = []
	var target_layer = ""
	if show_layer_type == "blocks":
		layer_array = current_layers.map_layers.get_children()
		target_layer = current_layers.get_target_map_layer()
		if current_layers.map_layers.get_child_count() > 1 and current_layers.map_layers.get_node(target_layer).get_index() > 0:
			move_up_button.disabled = false
		else:
			move_up_button.disabled = true
		if current_layers.map_layers.get_child_count() > 1 and current_layers.map_layers.get_node(target_layer).get_index() < current_layers.map_layers.get_child_count() - 1:
			move_down_button.disabled = false
		else:
			move_down_button.disabled = true
	if show_layer_type == "art":
		layer_array = current_layers.art_layers.get_children()
		target_layer = current_layers.get_target_art_layer()
		if current_layers.art_layers.get_child_count() > 1 and current_layers.art_layers.get_node(target_layer).get_index() > 0:
			move_up_button.disabled = false
		else:
			move_up_button.disabled = true
		if current_layers.art_layers.get_child_count() > 1 and current_layers.art_layers.get_node(target_layer).get_index() < current_layers.art_layers.get_child_count() - 1:
			move_down_button.disabled = false
		else:
			move_down_button.disabled = true
	var i: int = 0
	for layer in layer_array:
		if not (layer is MapLayer or layer is ArtLayer):
			continue
		i += 1
		var row = LAYER_ROW.instantiate()
		row.name = "LayerRow" + str(i)
		row.position.y = (row_holder.get_child_count() * 44)
		row.get_node("LayerNameButton").text = layer.layer_name
		row_holder.add_child(row)
		
		var layer_button = row.get_node("LayerNameButton")
		layer_button.pressed.connect(_row_pressed.bind(layer.name, layer_button))
		if target_layer == layer.name:
			layer_button.button_pressed = true
	update_boxes()


func update_boxes() -> void:
	var layer
	depth_container.visible = false
	alpha_container.visible = false
	if show_layer_type == "blocks":
		layer = current_layers.map_layers.get_node(current_layers.get_target_map_layer())
	if show_layer_type == "art":
		layer = current_layers.art_layers.get_node(current_layers.get_target_art_layer())
	if layer:
		if layer is MapLayer:
			z_axis_box.text = str(layer.z_axis)
			rotation_box.text = str(layer.tile_map_rotation)
		if layer is ArtLayer:
			depth_container.visible = true
			alpha_container.visible = true
			z_axis_box.text = str(layer.z_axis)
			depth_box.text = str(layer.depth)
			rotation_box.text = str(round(layer.art_rotation))
			alpha_box.text = str(layer.alpha)


func clear() -> void:
	for child in row_holder.get_children():
		child.free()


func _new_pressed():
	print("LayerPanel::add layer")
	if show_layer_type == "blocks":
		var i = current_layers.map_layers.get_child_count() + 1
		var new_name = "Layer " + str(i)
		while(current_layers.map_layers.get_node(new_name)):
			i += 1
			new_name = "Layer " + str(i)
		emit_signal("level_event", {
			"type": EditorEvents.ADD_MAP_LAYER,
			"name": new_name
		})
		call_deferred("render")
	if show_layer_type == "art":
		var i = current_layers.art_layers.get_child_count() + 1
		var new_name = "Layer " + str(i)
		while(current_layers.art_layers.get_node(new_name)):
			i += 1
			new_name = "Layer " + str(i)
		emit_signal("level_event", {
			"type": EditorEvents.ADD_ART_LAYER,
			"name": new_name
		})
		call_deferred("render")


func _delete_pressed():
	if show_layer_type == "blocks":
		emit_signal("level_event", {
			"type": EditorEvents.DELETE_MAP_LAYER,
			"name": current_layers.get_target_map_layer()
		})
		call_deferred("render")
	if show_layer_type == "art":
		emit_signal("level_event", {
			"type": EditorEvents.DELETE_ART_LAYER,
			"name": current_layers.get_target_art_layer()
		})
		call_deferred("render")


func _move_up_layer():
	if show_layer_type == "blocks":
		var layer = current_layers.map_layers.get_node(current_layers.get_target_map_layer())
		if layer.get_index() > 0:
			current_layers.map_layers.move_child(layer, layer.get_index() - 1)
			render()
	if show_layer_type == "art":
		var layer = current_layers.art_layers.get_node(current_layers.get_target_art_layer())
		if layer.get_index() > 0:
			current_layers.art_layers.move_child(layer, layer.get_index() - 1)
			render()


func _move_down_layer():
	if show_layer_type == "blocks":
		var layer = current_layers.map_layers.get_node(current_layers.get_target_map_layer())
		if layer.get_index() < current_layers.map_layers.get_child_count() - 1:
			current_layers.map_layers.move_child(layer, layer.get_index() + 1)
			render()
	if show_layer_type == "art":
		var layer = current_layers.art_layers.get_node(current_layers.get_target_art_layer())
		if layer.get_index() < current_layers.art_layers.get_child_count() - 1:
			current_layers.art_layers.move_child(layer, layer.get_index() + 1)
			render()


func _row_pressed(layer_name: String, layer_button: Button):
	if show_layer_type == "blocks":
		if current_layers.get_target_map_layer() == layer_name:
			var layer = current_layers.map_layers.get_node(current_layers.get_target_map_layer())
			rename_layer_popup.new_layer_name.text = layer.layer_name
			rename_layer_popup.popup(Rect2i(layer_button.global_position.x, layer_button.global_position.y, 288, 40))
		else:
			current_layers.set_target_map_layer(layer_name)
			emit_signal("control_event", {
				"type": EditorEvents.SELECT_MAP_LAYER,
				"layer_name": layer_name
			})
			call_deferred("render")
	if show_layer_type == "art":
		if current_layers.get_target_art_layer() == layer_name:
			var layer = current_layers.art_layers.get_node(current_layers.get_target_art_layer())
			rename_layer_popup.new_layer_name.text = layer.layer_name
			rename_layer_popup.popup(Rect2i(layer_button.global_position.x, layer_button.global_position.y, 288, 40))
		else:
			current_layers.set_target_art_layer(layer_name)
			emit_signal("control_event", {
				"type": EditorEvents.SELECT_ART_LAYER,
				"layer_name": layer_name
			})
			call_deferred("render")


func _z_axis_change(new_z_axis: int):
	if show_layer_type == "blocks" and new_z_axis != current_layers.map_layers.get_node(current_layers.get_target_map_layer()).z_axis:
		emit_signal("level_event", {
			"type": EditorEvents.SET_MAP_LAYER_Z_AXIS,
			"layer_name": current_layers.get_target_map_layer(),
			"z_axis": new_z_axis
		})
	elif show_layer_type == "art" and new_z_axis != current_layers.art_layers.get_node(current_layers.get_target_art_layer()).z_axis:
		emit_signal("level_event", {
			"type": EditorEvents.SET_ART_LAYER_Z_AXIS,
			"layer_name": current_layers.get_target_art_layer(),
			"z_axis": new_z_axis
		})


func _depth_change(new_depth: int):
	if show_layer_type == "art" and new_depth != current_layers.art_layers.get_node(current_layers.get_target_art_layer()).depth:
		emit_signal("level_event", {
			"type": EditorEvents.SET_ART_LAYER_DEPTH,
			"layer_name": current_layers.get_target_art_layer(),
			"depth": new_depth
		})


func _rotation_change(new_rotation: int):
	if show_layer_type == "blocks" and new_rotation != current_layers.map_layers.get_node(current_layers.get_target_map_layer()).tile_map_rotation:
		emit_signal("level_event", {
			"type": EditorEvents.SET_MAP_LAYER_ROTATION,
			"layer_name": current_layers.get_target_map_layer(),
			"rotation": new_rotation
		})
	elif show_layer_type == "art" and new_rotation != current_layers.art_layers.get_node(current_layers.get_target_art_layer()).art_rotation:
		emit_signal("level_event", {
			"type": EditorEvents.SET_ART_LAYER_ROTATION,
			"layer_name": current_layers.get_target_art_layer(),
			"rotation": int(new_rotation)
		})


func _alpha_change(new_alpha: int):
	if show_layer_type == "art" and new_alpha != current_layers.art_layers.get_node(current_layers.get_target_art_layer()).alpha:
		emit_signal("level_event", {
			"type": EditorEvents.SET_ART_LAYER_ALPHA,
			"layer_name": current_layers.get_target_art_layer(),
			"alpha": new_alpha
		})


func _set_layer_name(new_layer_name: String):
	if show_layer_type == "blocks" and current_layers.map_layers.get_node(current_layers.get_target_map_layer()).layer_name != new_layer_name:
		emit_signal("level_event", {
			"type": EditorEvents.RENAME_MAP_LAYER,
			"layer_name": current_layers.get_target_map_layer(),
			"new_layer_name": new_layer_name
		})
		rename_layer_popup.hide()
		render()
	elif show_layer_type == "art" and current_layers.art_layers.get_node(current_layers.get_target_art_layer()).layer_name != new_layer_name:
		emit_signal("level_event", {
			"type": EditorEvents.RENAME_ART_LAYER,
			"layer_name": current_layers.get_target_art_layer(),
			"new_layer_name": new_layer_name
		})
		rename_layer_popup.hide()
		render()
