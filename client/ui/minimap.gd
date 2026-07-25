extends Control
class_name Minimap

var game = null
var map_layers = null
var player = null
var dot_size = Vector2(10, 10)
@onready var display_layers = $DisplayLayers


func init(game_scene):
	game = game_scene
	map_layers = game_scene.level_manager.level_layers.map_layers
	player = game_scene.get_node("PlayerManager").get_character()
	
	for map_layer in map_layers.get_children():
		var minimap_layer = _create_minimap_layer(map_layer)
		minimap_layer.name = map_layer.name
		display_layers.add_child(minimap_layer)
	
	connect("resized", Callable(self, "_on_resized"))


func _on_resized():
	for child in display_layers.get_children():
		_update_minimap_layer_scale(child)


func _create_minimap_layer(map_layer: MapLayer):
	var tile_map_layer_mini = ConfigurableTileMapLayer.new()
	tile_map_layer_mini.tile_set = BlockManager._tile_set
	
	var used_cells = map_layer.tile_map_layer.get_all_block_coords()
	for cell in used_cells:
		var block_id = map_layer.tile_map_layer.get_block(cell).id
		tile_map_layer_mini.add_block(cell, block_id)

	_update_minimap_layer_scale(tile_map_layer_mini)
	
	return tile_map_layer_mini


func _update_minimap_layer_scale(minimap_layer: ConfigurableTileMapLayer):
	var used_rect = minimap_layer.get_used_rect()
	
	var scaleX = 1.0
	if used_rect.size.x > 0:
		scaleX = size.x / (used_rect.size.x * Settings.tile_size.x)
	
	var scaleY = 1.0
	if used_rect.size.y > 0:
		scaleY = size.y / (used_rect.size.y * Settings.tile_size.y)
		
	var effective_scale = min(scaleX, scaleY) * 0.9
	
	minimap_layer.scale = Vector2(effective_scale, effective_scale)
	
	var new_position = Vector2.ZERO
	new_position.x = (size.x - (used_rect.size.x * Settings.tile_size.x * effective_scale)) / 2
	new_position.y = (size.y - (used_rect.size.y * Settings.tile_size.y * effective_scale)) / 2
	
	new_position.x -= used_rect.position.x * Settings.tile_size.x * effective_scale
	new_position.y -= used_rect.position.y * Settings.tile_size.y * effective_scale
	
	minimap_layer.position = new_position


func _process(_delta):
	if not is_instance_valid(player):
		return
	
	for child in display_layers.get_children():
		if child.name == game.get_current_player_layer():
			child.visible = true
			var player_marker = child.get_node_or_null("PlayerMarker")
			if not player_marker:
				player_marker = ColorRect.new()
				player_marker.name = "PlayerMarker"
				player_marker.color = Color.RED
				player_marker.size = dot_size * (Vector2.ONE / child.scale)
				child.add_child(player_marker)
			
			player_marker.position = player.position - (player_marker.size / 2)
		else:
			child.visible = false
			var player_marker = child.get_node_or_null("PlayerMarker")
			if player_marker:
				child.free()
