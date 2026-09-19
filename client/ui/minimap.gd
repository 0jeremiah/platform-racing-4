extends Control
class_name Minimap

var game = null
var map_layers = null
var player = null
var dot_size = Vector2(10, 10)
var layer_scale = Vector2(1.0, 1.0)
@onready var display_layers = $DisplayLayers


func init(game_scene):
	game = game_scene
	map_layers = game_scene.level_manager.level_layers.map_layers
	player = game_scene.get_node("PlayerManager").get_character()
	
	for map_layer in map_layers.get_children():
		var minimap_layer = _create_minimap_layer(map_layer)
		minimap_layer.name = map_layer.name
		display_layers.add_child(minimap_layer)
	
	#connect("resized", Callable(self, "_on_resized"))


#func _on_resized():
	#for child in display_layers.get_children():
		#_update_minimap_layer_scale(child)


func _create_minimap_layer(map_layer: MapLayer):
	var used_cells = map_layer.tile_map_layer.get_all_block_coords()
	var used_rect = map_layer.tile_map_layer.get_used_rect()
	var scaleX = 1.0
	if used_rect.size.x > 0:
		scaleX = size.x / (used_rect.size.x * Settings.tile_size.x)
	var scaleY = 1.0
	if used_rect.size.y > 0:
		scaleY = size.y / (used_rect.size.y * Settings.tile_size.y)
	var effective_scale = min(scaleX, scaleY) * 0.9
	var minimap_width = clampi(int((used_rect.size.x * Settings.tile_size.x) * effective_scale), 1, 1280)
	var minimap_height = clampi(int((used_rect.size.y * Settings.tile_size.y) * effective_scale), 1, 1280)
	var minimap_x_offset = used_rect.position.x * -1
	var minimap_y_offset = used_rect.position.y * -1
	var minimap_texture = DrawableTexture2D.new()
	minimap_texture.setup(minimap_width, minimap_height, DrawableTexture2D.DRAWABLE_FORMAT_RGBA8, Color(1.0, 1.0, 1.0, 0.0), false)
	var block_id = ""
	var block_texture = null
	for used_cell in used_cells:
		var block_info = map_layer.tile_map_layer.get_block(used_cell)
		if block_info.id == "":
			continue
		var teleport_color = ConfigurableBlockSettings.default_block_properties.teleport_color
		if block_info.settings != null:
			teleport_color = block_info.settings.teleport_color
		if block_id != block_info.id:
			block_id = block_info.id
			block_texture = BlockManager.new_get_block_texture(block_id, teleport_color).get_image()
		var block_size = Vector2i(max(int(Settings.tile_size.x * effective_scale), 2), max(int(Settings.tile_size.y * effective_scale), 2))
		block_texture.resize(block_size.x, block_size.y)
		var block_image = ImageTexture.create_from_image(block_texture)
		var block_position = Vector2i(int((used_cell.x + minimap_x_offset) * (Settings.tile_size.x * effective_scale)), int((used_cell.y + minimap_y_offset) * (Settings.tile_size.y * effective_scale)))
		minimap_texture.blit_rect(Rect2i(block_position, block_size), block_image)
	var minimap_sprite = Sprite2D.new()
	minimap_sprite.texture = minimap_texture
	minimap_sprite.visible = false
	minimap_sprite.position = Vector2(size.x / 2, size.y / 2)
	return minimap_sprite


func _process(_delta):
	if not is_instance_valid(player):
		return
	
	for child in display_layers.get_children():
		if child.name == game.get_current_player_layer():
			var map_layer = map_layers.get_node_or_null(game.get_current_player_layer())
			if map_layer:
				var used_rect = map_layer.tile_map_layer.get_used_rect()
				var scaleX = 1.0
				if used_rect.size.x > 0:
					scaleX = size.x / (used_rect.size.x * Settings.tile_size.x)
				var scaleY = 1.0
				if used_rect.size.y > 0:
					scaleY = size.y / (used_rect.size.y * Settings.tile_size.y)
				var effective_scale = min(scaleX, scaleY) * 0.9
				layer_scale = effective_scale
			child.visible = true
			var player_marker = child.get_node_or_null("PlayerMarker")
			if not player_marker:
				player_marker = ColorRect.new()
				player_marker.name = "PlayerMarker"
				player_marker.color = Color.RED
				player_marker.size = dot_size * (Vector2.ONE * child.scale)
				child.add_child(player_marker)
			
			player_marker.position = player.position - (player_marker.size / 2)
		else:
			child.visible = false
			var player_marker = child.get_node_or_null("PlayerMarker")
			if player_marker:
				child.free()
