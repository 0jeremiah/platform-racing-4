extends Node2D

@onready var tile_map_layers = $TileMapLayers
@onready var panel = $Panel
@onready var display_layers = $DisplayLayers


func _ready() -> void:
	for tile_map_layer in tile_map_layers.get_children():
		var used_coords = tile_map_layer.get_used_cells()
		var used_rect = tile_map_layer.get_used_rect()
		create_display_layer(used_coords, used_rect)
	display_layers.get_child(randi_range(0, display_layers.get_child_count() - 1)).visible = true


func create_display_layer(used_coords: Array[Vector2i], used_rect: Rect2i, layer_name: String = ""):
	var scaleX = 1.0
	if used_rect.size.x > 0:
		scaleX = panel.size.x / (used_rect.size.x * Settings.tile_size.x)
	var scaleY = 1.0
	if used_rect.size.y > 0:
		scaleY = panel.size.y / (used_rect.size.y * Settings.tile_size.y)
	var effective_scale = min(scaleX, scaleY) * 0.9
	var minimap_width = 1
	if used_rect.size.x > 0:
		minimap_width = clampi(int((used_rect.size.x * Settings.tile_size.x) * effective_scale), 1, 1280)
	var minimap_height = 1
	if used_rect.size.y > 0:
		minimap_height = clampi(int((used_rect.size.y * Settings.tile_size.y) * effective_scale), 1, 1280)
	var minimap_x_offset = used_rect.position.x * -1
	var minimap_y_offset = used_rect.position.y * -1
	var minimap_texture = DrawableTexture2D.new()
	minimap_texture.setup(minimap_width, minimap_height, DrawableTexture2D.DRAWABLE_FORMAT_RGBA8, Color(1.0, 1.0, 1.0, 0.0), false)
	for used_coord in used_coords:
		var block_texture = BlockManager.new_get_block_texture("1").get_image()
		var block_size = Vector2i(max(int(Settings.tile_size.x * effective_scale), 1), max(int(Settings.tile_size.y * effective_scale), 1))
		block_texture.resize(block_size.x, block_size.y)
		var block_image = ImageTexture.create_from_image(block_texture)
		var block_position = Vector2i(int((used_coord.x + minimap_x_offset) * (Settings.tile_size.x * effective_scale)), int((used_coord.y + minimap_y_offset) * (Settings.tile_size.y * effective_scale)))
		minimap_texture.blit_rect(Rect2i(block_position, block_size), block_image)
	var minimap_sprite = Sprite2D.new()
	minimap_sprite.texture = minimap_texture
	minimap_sprite.visible = false
	minimap_sprite.position = Vector2(display_layers.size.x / 2, display_layers.size.y / 2)
	if layer_name:
		minimap_sprite.name = layer_name
	display_layers.add_child(minimap_sprite)
