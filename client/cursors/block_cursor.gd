extends Node2D

signal level_event

@onready var eraser_icon = $EraserIcon
@onready var block_icon = $BlockIcon
@onready var teleport_colorin = $BlockIcon/TeleportColorin

var active: bool = false
var mode: String = "draw"
var block_id: int = 0
var block_options = null
var teleport_colorin_coords: Vector2 = Vector2(-1, -1)
var teleport_color: String = "FFFFFF"
var grabbed_block: int = 0
var grabbed_block_options: Array = []
var level_layers: LevelLayers


func _ready():
	pass


func deactivate():
	active = false


func activate():
	active = true


#func _draw():
	#var camera: Camera2D = get_viewport().get_camera_2d()
	#var screen_rect = get_viewport().get_visible_rect()
	#if camera:
		#var layer: Parallax2D = level_layers.map_layers.get_node(level_layers.get_target_map_layer())
		#var packed_vector2_array = PackedVector2Array(
		#[Vector2((-get_parent().position.x + screen_rect.position.x) * layer.get_layer_scale(), (-get_parent().position.y + screen_rect.position.y) * layer.get_layer_scale()),
		#Vector2((-get_parent().position.x + screen_rect.position.x + screen_rect.size.x) * layer.get_layer_scale(), (-get_parent().position.y + screen_rect.position.y) * layer.get_layer_scale()),
		#Vector2((-get_parent().position.x + screen_rect.position.x + screen_rect.size.x) * layer.get_layer_scale(), (-get_parent().position.y + screen_rect.position.y + screen_rect.size.y) * layer.get_layer_scale()),
		#Vector2((-get_parent().position.x + screen_rect.position.x) * layer.get_layer_scale(), (screen_rect.position.y + -get_parent().position.y + screen_rect.size.y) * layer.get_layer_scale())])
		#for lines in packed_vector2_array.size():
			#if lines + 1 < packed_vector2_array.size():
				#draw_line(packed_vector2_array[lines], packed_vector2_array[lines + 1], Color.WHITE, 5.0, false)
			#else:
				#draw_line(packed_vector2_array[lines], packed_vector2_array[0], Color.WHITE, 5.0, false)


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
			elif mode == "move" and grabbed_block > 0 or mode == "draw":
				block_icon.visible = true
				var atlas_coords: Vector2i = Vector2i(-1, -1)
				if mode == "move":
					atlas_coords = CoordinateUtils.to_atlas_coords(grabbed_block)
				else:
					atlas_coords = CoordinateUtils.to_atlas_coords(block_id)
				block_icon.texture.region = Rect2((128 * atlas_coords.x), (128 * atlas_coords.y), 128, 128)
				if teleport_colorin_coords != Vector2(-1, -1):
					teleport_colorin.visible = true
					teleport_colorin.texture.region = Rect2((128 * teleport_colorin_coords.x), (128 * teleport_colorin_coords.y), 128, 128)
					teleport_colorin.self_modulate = Color(teleport_color + "7F")
			#queue_redraw()
	else:
		visible = false


func init(_editor_menu, _level_layers) -> void:
	print("BlockCursor::init")
	if _level_layers is LevelLayers:
		level_layers = _level_layers
		_editor_menu.connect("control_event", _on_control_event)
	

func _on_control_event(event: Dictionary) -> void:
	print("BlockCursor::_on_control_event", event)
	if event.type == EditorEvents.SELECT_BLOCK_MODE:
		mode = event.mode
	if event.type == EditorEvents.SELECT_BLOCK:
		block_id = event.block_id
		#if event.has("block_options"):
			#block_options = event.block_options
		#else:
			#block_options = null
		if (event.has("teleport_colorin_coords") and event.teleport_colorin_coords != null):
			teleport_colorin_coords = event.teleport_colorin_coords
			teleport_color = event.teleport_color
		else:
			teleport_colorin_coords = Vector2(-1, -1)
			teleport_color = "FFFFFF"
			


func get_mouse_to_tilemap_coords() -> Vector2:
	if level_layers:
		var layer: Parallax2D = level_layers.map_layers.get_node(level_layers.get_target_map_layer())
		var tile_map_layer: TileMapLayer = layer.tile_map_layer
		var camera: Camera2D = get_viewport().get_camera_2d()
		var rotated_pos: Vector2

		# Get screen position of mouse
		var viewport_mouse_pos = get_viewport().get_mouse_position()
		
		# Convert to world position taking into account camera position, zoom, and layer scale
		#print(layer.get_layer_scale())
		var world_pos = ((viewport_mouse_pos / layer.get_layer_scale()) - (get_viewport_rect().size / 2)) / camera.zoom
		world_pos += camera.position
		
		# Adjust for layer depth scaling
		#world_pos *= layer.get_layer_scale()
		
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
	if active and level_layers and mode == "move":
		var layer: Parallax2D = level_layers.map_layers.get_node(level_layers.get_target_map_layer())
		var tile_map_layer: TileMapLayer = layer.tile_map_layer
		var coords = tile_map_layer.local_to_map(get_mouse_to_tilemap_coords())
		var tile_coords = tile_map_layer.get_cell_atlas_coords(coords)
		var tile_id = CoordinateUtils.to_block_id(tile_coords)
		#var tile_options = null
		#var tile_data = tile_map_layer.get_cell_tile_data(coords)
		#if tile_data and tile_data.has_custom_data("tile_options"):
			#tile_options = tile_data.get_custom_data("tile_options")
		if tile_id > 0:
			grabbed_block = tile_id
			#grabbed_block_options = tile_options
			emit_signal("level_event", {
				"type": EditorEvents.SET_TILE,
				"layer_name": level_layers.get_target_map_layer(),
				"coords": {
					"x": coords.x,
					"y": coords.y
				},
				"block_id": 0,
				"block_options": null,
				"atlas_coords": Vector2(-1, -1)
			})

func on_drag():
	if active and level_layers and (mode == "draw" or mode == "erase"):
		var layer: Parallax2D = level_layers.map_layers.get_node(level_layers.get_target_map_layer())
		var tile_map_layer: TileMapLayer = layer.tile_map_layer
		var coords = tile_map_layer.local_to_map(get_mouse_to_tilemap_coords())
		var tile_id: int
		#var tile_options: TileOptions
		if mode == "erase":
			tile_id = 0
			#tile_options = null
		else:
			tile_id = block_id
			#tile_options = block_options
		var atlas_coords = CoordinateUtils.to_atlas_coords(tile_id)
		var existing_atlas_coords = tile_map_layer.get_cell_atlas_coords(coords)
		if atlas_coords != existing_atlas_coords:
			emit_signal("level_event", {
				"type": EditorEvents.SET_TILE,
				"layer_name": level_layers.get_target_map_layer(),
				"coords": {
					"x": coords.x,
					"y": coords.y
				},
				"block_id": tile_id,
				#"block_options": tile_options,
				"atlas_coords": atlas_coords
			})


func on_mouse_up():
	if active and level_layers and mode == "move":
		var layer: Parallax2D = level_layers.map_layers.get_node(level_layers.get_target_map_layer())
		var tile_map_layer: TileMapLayer = layer.tile_map_layer
		var coords = tile_map_layer.local_to_map(get_mouse_to_tilemap_coords())
		var atlas_coords = CoordinateUtils.to_atlas_coords(grabbed_block)
		if grabbed_block > 0:
			emit_signal("level_event", {
				"type": EditorEvents.SET_TILE,
				"layer_name": level_layers.get_target_map_layer(),
				"coords": {
					"x": coords.x,
					"y": coords.y
				},
				"block_id": grabbed_block,
				"block_options": grabbed_block_options,
				"atlas_coords": atlas_coords
			})
			grabbed_block = 0
			#grabbed_block_options = []
