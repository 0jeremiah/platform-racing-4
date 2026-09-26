extends Node2D

signal editor_event

@onready var eraser_icon = $EraserIcon
@onready var block_icon = $BlockIcon
@onready var teleport_colorin = $BlockIcon/TeleportColorin

var active: bool = false
var level_layers: LevelLayers
var cursor_parent = null
var mode: String = "draw"
var block_id: String = "601"
var block_settings: ConfigurableBlockSettings = ConfigurableBlockSettings.new()
var grabbed_block_id: String = ""
var grabbed_block_settings: ConfigurableBlockSettings = null


func _ready():
	pass


func deactivate():
	active = false


func activate():
	active = true


func _process(_delta):
	if active:
		visible = true
		eraser_icon.visible = false
		block_icon.visible = false
		teleport_colorin.visible = false
		var touching_gui: bool = get_parent().touching_gui
		if touching_gui:
			if mode == "erase":
				eraser_icon.visible = true
			elif mode == "move" and grabbed_block_id or mode == "draw":
				block_icon.visible = true
				var current_block_id = block_id
				var current_block_settings = block_settings
				if mode == "move":
					current_block_id = grabbed_block_id
					current_block_settings = grabbed_block_settings
				block_icon.texture = BlockManager.get_block_texture(current_block_id)
				if current_block_settings.has_side_type(ConfigurableBlockSideSettings.TELEPORT):
					teleport_colorin.texture = BlockManager.get_block_teleport_texture(current_block_id)
					teleport_colorin.self_modulate = current_block_settings.teleport_color
					teleport_colorin.visible = true
	else:
		visible = false


func init(_level_layers, _cursor_parent) -> void:
	print("BlockCursor::init")
	if _level_layers is LevelLayers:
		level_layers = _level_layers
	cursor_parent = _cursor_parent
	cursor_parent.editor_menu.connect("control_event", _on_control_event)
	

func _on_control_event(event: Dictionary) -> void:
	if active:
		print("BlockCursor::_on_control_event", event)
		if event.type == EditorEvents.SELECT_BLOCK_MODE:
			mode = event.mode
		if event.type == EditorEvents.SELECT_BLOCK:
			block_id = event.block_id
			block_settings = event.block_settings


func get_mouse_to_tilemap_coords() -> Vector2:
	if level_layers:
		var layer: Parallax2D = level_layers.map_layers.get_node(level_layers.get_target_map_layer())
		var camera: Camera2D = get_viewport().get_camera_2d()
		var rotated_pos: Vector2

		# Get screen position of mouse
		var viewport_mouse_pos = get_viewport().get_mouse_position()

		# Convert to world position taking into account camera position, zoom, and layer scale
		var world_pos = layer.to_local(((viewport_mouse_pos - (get_viewport_rect().size / 2)) / camera.zoom) + camera.get_screen_center_position())

		# Account for tilemap rotation
		rotated_pos = world_pos
		if layer.tile_map_rotation != 0:
			# Inverse rotate the point to get the correct position in rotated space
			var rotation_radians = -deg_to_rad(layer.tile_map_rotation)
			rotated_pos = Vector2(
				world_pos.x * cos(rotation_radians) - world_pos.y * sin(rotation_radians),
				world_pos.x * sin(rotation_radians) + world_pos.y * cos(rotation_radians)
			)
		return rotated_pos
	return Vector2(-1, -1)


func on_mouse_down():
	if active and cursor_parent.editor_menu.can_edit and level_layers and mode == "move":
		var layer: Parallax2D = level_layers.map_layers.get_node(level_layers.get_target_map_layer())
		var tile_map_layer: TileMapLayer = layer.tile_map_layer
		var coords = tile_map_layer.local_to_map(get_mouse_to_tilemap_coords())
		var tile_id = tile_map_layer.get_block(coords).id
		if tile_id:
			var tile_settings_info = tile_map_layer.get_block_settings_info(coords)
			if "object_box" in cursor_parent.editor_menu.current_editor:
				var object_box = cursor_parent.editor_menu.current_editor.object_box
				object_box.close()
			grabbed_block_id = tile_id
			grabbed_block_settings = ConfigurableBlockSettings.new()
			grabbed_block_settings.import_settings(tile_settings_info.settings)
			grabbed_block_settings.import_edited_settings(tile_settings_info.edited_settings)
			emit_signal("editor_event", {
				"type": EditorEvents.SET_TILE,
				"layer_name": level_layers.get_target_map_layer(),
				"coords": {
					"x": coords.x,
					"y": coords.y
				},
				"block_id": 0,
				"block_settings_info": {"settings": tile_settings_info.settings, "edited_settings": tile_settings_info.edited_settings}
			})

func on_drag():
	if active and cursor_parent.editor_menu.can_edit and level_layers and (mode == "draw" or mode == "erase"):
		var layer: Parallax2D = level_layers.map_layers.get_node(level_layers.get_target_map_layer())
		var tile_map_layer: TileMapLayer = layer.tile_map_layer
		var coords = tile_map_layer.local_to_map(get_mouse_to_tilemap_coords())
		var tile_id: String
		var tile_settings_info: Dictionary
		if mode == "erase":
			tile_id = ""
			tile_settings_info = {"settings": {}, "edited_settings": {}}
		else:
			tile_id = block_id
			tile_settings_info = {"settings": block_settings.get_settings(), "edited_settings": block_settings.get_edited_settings()}
		var existing_tile_id = tile_map_layer.get_block(coords).id
		var existing_tile_settings_info = tile_map_layer.get_block_settings_info(coords)
		if tile_id != existing_tile_id or tile_settings_info != existing_tile_settings_info:
			emit_signal("editor_event", {
				"type": EditorEvents.SET_TILE,
				"layer_name": level_layers.get_target_map_layer(),
				"coords": {
					"x": coords.x,
					"y": coords.y
				},
				"block_id": tile_id,
				"block_settings_info": tile_settings_info
			})


func on_mouse_up():
	if active and cursor_parent.editor_menu.can_edit and level_layers and mode == "move":
		var layer: Parallax2D = level_layers.map_layers.get_node(level_layers.get_target_map_layer())
		var tile_map_layer: TileMapLayer = layer.tile_map_layer
		var coords = tile_map_layer.local_to_map(get_mouse_to_tilemap_coords())
		if grabbed_block_id:
			var grabbed_block_settings_info = {"settings": {}, "edited_settings": {}}
			if grabbed_block_settings:
				grabbed_block_settings_info.settings = grabbed_block_settings.get_settings()
				grabbed_block_settings_info.edited_settings = grabbed_block_settings.get_edited_settings()
			emit_signal("editor_event", {
				"type": EditorEvents.SET_TILE,
				"layer_name": level_layers.get_target_map_layer(),
				"coords": {
					"x": coords.x,
					"y": coords.y
				},
				"block_id": grabbed_block_id,
				"block_settings_info": grabbed_block_settings_info
			})
			if "object_box" in get_parent().editor_menu.current_editor:
				var object_box = get_parent().editor_menu.current_editor.object_box
				var spawn_position = coords * Settings.tile_size
				var block_texture = Sprite2D.new()
				block_texture.texture = BlockManager.get_block_texture(grabbed_block_id)
				object_box.set_object_info({"delete": true, "resize": false, "options": true, "text": false},
				{"type": "block", "node": block_texture, "position": spawn_position, "rotation": 0,
				"offset": Vector2(0, 0), "size": Settings.tile_size, "scale": Vector2(1, 1),
				"info": level_layers.get_target_map_layer()})
			grabbed_block_id = ""
			grabbed_block_settings = null
