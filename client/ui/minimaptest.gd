extends Node2D

@onready var tile_map_layers = $TileMapLayers
@onready var panel = $Panel
@onready var display_layers = $DisplayLayers


func _ready() -> void:
	for tile_map_layer in tile_map_layers.get_children():
		var used_coords = tile_map_layer.get_used_cells()
		var used_rect = tile_map_layer.get_used_rect()
		create_display_layer(used_coords, used_rect)
	display_layers.get_child(randi_range(0, display_layers.get_child_count())).visible = true


func create_display_layer(used_coords: Array[Vector2i], used_rect: Rect2i, layer_name: String = ""):
	var control = Control.new()
	var scaleX = 1.0
	if used_rect.size.x > 0:
		scaleX = panel.size.x / (used_rect.size.x * Settings.tile_size.x)
	var scaleY = 1.0
	if used_rect.size.y > 0:
		scaleY = panel.size.y / (used_rect.size.y * Settings.tile_size.y)
	var effective_scale = min(scaleX, scaleY) * 0.9
	control.scale = Vector2(effective_scale, effective_scale)
	var new_position = Vector2.ZERO
	new_position.x = (panel.size.x - (used_rect.size.x * Settings.tile_size.x * effective_scale)) / 2
	new_position.y = (panel.size.y - (used_rect.size.y * Settings.tile_size.y * effective_scale)) / 2
	new_position.x -= used_rect.position.x * Settings.tile_size.x * effective_scale
	new_position.y -= used_rect.position.y * Settings.tile_size.y * effective_scale
	control.position = new_position
	for used_coord in used_coords:
		var block_sprite = Sprite2D.new()
		block_sprite.texture = BlockManager.get_block_texture("1")
		block_sprite.position = used_coord * Settings.tile_size
		control.add_child(block_sprite)
		control.visible = false
		if layer_name:
			control.name = layer_name
	display_layers.add_child(control)
