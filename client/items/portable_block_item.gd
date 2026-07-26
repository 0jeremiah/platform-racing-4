extends Item
class_name PortableBlockItem

@onready var visual_aid = $VisualAid
@onready var block_icon = $BlockIcon
var tile_id = ""
var tile_map_layer: TileMapLayer
var spawn_position: Vector2
var tile_map_layer_position: Vector2
var coords: Vector2i
var atlas_coords: Vector2i
var below_zero: Vector2
var can_place: bool


func _ready():
	tile_id = "portable_block"
	visual_aid.texture = BlockManager.get_block_texture(tile_id)
	block_icon.texture = BlockManager.get_block_texture(tile_id)


func _init_item(_character: Character):
	_character.item_manager.uses = GameConfig.get_value("items-uses", "uses_portable_block")


func process_item(_character: Character) -> void:
	set_block_position(_character)
	set_visuals(_character)


func set_block_position(_character: Character):
	can_place = false
	var layer = Game.get_target_map_layer_node()
	tile_map_layer = layer.tile_map_layer
	coords = tile_map_layer.get_block_position_at_local_position(Vector2(_character.global_position.x + (Settings.tile_size_half.x * _character.movement.facing), _character.global_position.y - Settings.tile_size_half.y))
	if !tile_map_layer.is_solid(coords):
		can_place = true


func set_visuals(_character: Character):
	_character.item_manager.position = Vector2(_character.item_holder_display.position.x * _character.movement.facing, _character.item_holder_display.position.y)
	_character.item_manager.rotation = _character.item_holder_display.rotation * _character.movement.facing
	_character.item_manager.scale = (_character.item_holder_display.scale / _character.movement.size) * _character.display.scale
	_character.item_manager.modulate = _character.display.modulate
	_character.item_manager.z_index = _character.item_holder_display.z_index
	visual_aid.global_position = tile_map_layer.get_block_center_position(coords)
	visual_aid.global_rotation = tile_map_layer.rotation
	visual_aid.scale.x = 2.222
	visual_aid.scale.y = 2.222
	if can_place:
		visual_aid.self_modulate = Color(0.625, 1, 0.625, 0.5)
	else:
		visual_aid.self_modulate = Color(1, 0.625, 0.625, 0.5)
	block_icon.position = Vector2(0, 0)
	block_icon.rotation = _character.item_holder_display.rotation
	block_icon.scale = (_character.item_holder_display.scale / _character.movement.size) * _character.display.scale
	block_icon.modulate = _character.display.modulate
	block_icon.z_index = _character.item_holder_display.z_index


func activate_item(_character: Character):
	if !_character.item_manager.using and can_place:
		_character.item_manager.using = true
		_character.item_manager.reload_timer = GameConfig.get_value("items-uses", "reload_portable_block")
		use_block(_character)
		_character.item_manager.uses -= 1


func use_block(_character: Character):
	set_block_position(_character)
	TileEffects.spawn(tile_map_layer, coords, tile_id)
