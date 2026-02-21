extends Item
class_name PortableBlockItem

@onready var VisualAid = $VisualAid
var icon: Sprite2D
var tile_id = 0
var tile_map_layer: TileMapLayer
var spawn_position: Vector2
var tile_map_layer_position: Vector2
var coords: Vector2i
var atlas_coords: Vector2i
var below_zero: Vector2
var can_place: bool
var PortableBlock := load("res://item_effects/portable_block.tscn")


func _ready():
	tile_id = 45
	icon = $PortableBlockIcon


func _init_item(_character: Character):
	_character.item_manager.uses = GameConfig.get_value("items-uses", "uses_portable_block")


func process_item(_character: Character) -> void:
	set_block_position(_character)
	set_visuals(_character)


func set_block_position(_character: Character):
	can_place = false
	var layer = Game.get_target_block_layer_node()
	tile_map_layer = layer.tile_map_layer
	spawn_position = to_local(Vector2(0, 0))
	tile_map_layer_position = tile_map_layer.to_local(_character.global_position)
	coords = Vector2i(tile_map_layer_position.floor()) / Settings.tile_size
	if _character.movement.facing > 0 and floor(_character.global_position.x / Settings.tile_size.x) != round(_character.global_position.x / Settings.tile_size.x):
		coords.x = coords.x + 1
	elif _character.movement.facing < 0 and ceil(_character.global_position.x / Settings.tile_size.x) != round(_character.global_position.x / Settings.tile_size.x):
		coords.x = coords.x - 1
	if round((_character.global_position.y + (Settings.tile_size.y / 2)) / Settings.tile_size.y) != round(_character.global_position.y / Settings.tile_size.y):
		coords.y = coords.y - 1
	atlas_coords = CoordinateUtils.to_atlas_coords(tile_id)
	below_zero = Vector2(1, 1)
	if _character.global_position.x < 0:
		below_zero.x = -1
	if _character.global_position.y < 0:
		below_zero.y = -1
	var tile_data = tile_map_layer.get_cell_source_id(coords)
	if tile_data == -1:
		can_place = true


func set_visuals(_character: Character):
	_character.item_manager.position = Vector2(_character.item_holder_display.position.x * _character.movement.facing, _character.item_holder_display.position.y)
	_character.item_manager.rotation = _character.item_holder_display.rotation * _character.movement.facing
	_character.item_manager.scale = (_character.item_holder_display.scale / _character.movement.size) * _character.display.scale
	_character.item_manager.modulate = _character.display.modulate
	_character.item_manager.z_index = _character.item_holder_display.z_index
	VisualAid.global_position = Vector2i((coords.x * Settings.tile_size.x) + ((Settings.tile_size.x / 2) * below_zero.x), (coords.y * Settings.tile_size.y) + ((Settings.tile_size.y / 2) * below_zero.y))
	VisualAid.global_rotation = 0
	VisualAid.scale.x = 2.222
	VisualAid.scale.y = 2.222
	if can_place:
		VisualAid.self_modulate = Color(0.625, 1, 0.625, 0.5)
	else:
		VisualAid.self_modulate = Color(1, 0.625, 0.625, 0.5)
	icon.position = Vector2(0, 0)
	icon.rotation = _character.item_holder_display.rotation
	icon.scale = (_character.item_holder_display.scale / _character.movement.size) * _character.display.scale
	icon.modulate = _character.display.modulate
	icon.z_index = _character.item_holder_display.z_index


func activate_item(_character: Character):
	if !_character.item_manager.using and can_place:
		_character.item_manager.using = true
		_character.item_manager.reload_timer = GameConfig.get_value("items-uses", "reload_portable_block")
		use_block(_character)
		_character.item_manager.uses -= 1


func use_block(_character: Character):
	set_block_position(_character)
	var block = PortableBlock.instantiate()
	block.global_position = Vector2i((coords.x * Settings.tile_size.x) + ((Settings.tile_size.x / 2) * below_zero.x), (coords.y * Settings.tile_size.y) + ((Settings.tile_size.y / 2) * below_zero.y))
	block.tile_map_layer = tile_map_layer
	below_zero = Vector2(0, 0)
	if _character.global_position.x < 0:
		below_zero.x = -1
	if _character.global_position.y < 0:
		below_zero.y = -1
	block.coords = Vector2i(coords.x + below_zero.x, coords.y + below_zero.y)
	block.atlas_coords = atlas_coords
	var layer = Game.get_target_block_layer_node()
	var spawn = layer.get_node("Effects")
	spawn.add_child.call_deferred(block)
