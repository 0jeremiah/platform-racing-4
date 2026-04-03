extends Item
class_name TeleportItem

@onready var visual_aid = $VisualAid
@onready var teleport_icon = $TeleportIcon
@onready var poof_effect = preload("res://item_effects/poof_effect.tscn")

var teleport_horizontal_distance: float = 0.0
var teleport_vertical_distance: float = 0.0
var teleport_target_area = Vector2(0, 0)
var tile_map_layer: TileMapLayer
var tile_map_layer_position: Vector2
var coords: Vector2i
var atlas_coords: Vector2i
var below_zero: Vector2
var can_teleport: bool


func _init_item(_character: Character):
	teleport_horizontal_distance = GameConfig.get_value("items-effects", "teleport_horizontal_distance")
	teleport_vertical_distance = GameConfig.get_value("items-effects", "teleport_vertical_distance")
	_character.item_manager.uses = GameConfig.get_value("items-uses", "uses_teleport")


func process_item(_character: Character) -> void:
	maybe_teleport(_character)
	set_visuals(_character)


func maybe_teleport(_character: Character):
	can_teleport = false
	var layer = Game.get_target_map_layer_node()
	teleport_target_area = Vector2(_character.global_position.x + (Settings.tile_size.x * (teleport_horizontal_distance + 1)) * _character.movement.facing, _character.global_position.y + ((Settings.tile_size.y * teleport_vertical_distance) - (Settings.tile_size.y / 2)))
	tile_map_layer = layer.tile_map_layer
	tile_map_layer_position = tile_map_layer.local_to_map(teleport_target_area)
	coords = Vector2i(tile_map_layer_position.floor()) / Settings.tile_size
	#if _character.movement.facing > 0 and floor(teleport_target_area.x / Settings.tile_size.x) != round(teleport_target_area.x / Settings.tile_size.x):
		#coords.x = coords.x + 1
	#elif _character.movement.facing < 0 and ceil(teleport_target_area.x / Settings.tile_size.x) != round(teleport_target_area.x / Settings.tile_size.x):
		#coords.x = coords.x - 1
	#if round((teleport_target_area.y + (Settings.tile_size.y / 2)) / Settings.tile_size.y) != round(teleport_target_area.y / Settings.tile_size.y):
		#coords.y = coords.y - 1
	below_zero = Vector2(1, 1)
	if teleport_target_area.x < 0:
		below_zero.x = 0
	if teleport_target_area.y < 0:
		below_zero.y = 0
	var tile_data = tile_map_layer.get_cell_source_id(coords)
	if tile_data == -1:
		can_teleport = true


func set_visuals(_character: Character):
	_character.item_manager.position = Vector2(_character.item_holder_display.position.x * _character.movement.facing, _character.item_holder_display.position.y)
	_character.item_manager.rotation = _character.item_holder_display.rotation * _character.movement.facing
	_character.item_manager.scale = (_character.item_holder_display.scale / _character.movement.size) * _character.display.scale
	_character.item_manager.modulate = _character.display.modulate
	_character.item_manager.z_index = _character.item_holder_display.z_index
	visual_aid.global_position = Vector2(Settings.tile_size.x * tile_map_layer_position.x, Settings.tile_size.y * tile_map_layer_position.y)
	visual_aid.global_rotation = 0
	visual_aid.scale.x = 2.0
	visual_aid.scale.y = 2.0
	if can_teleport:
		visual_aid.self_modulate = Color(0.373, 1.0, 0.373, 0.5)
	else:
		visual_aid.self_modulate = Color(1.0, 0.373, 0.373, 0.5)
	teleport_icon.position = Vector2(0, 0)
	teleport_icon.rotation = _character.item_holder_display.rotation
	teleport_icon.scale = (_character.item_holder_display.scale / _character.movement.size) * _character.display.scale
	teleport_icon.modulate = _character.display.modulate
	teleport_icon.z_index = _character.item_holder_display.z_index


func activate_item(_character: Character):
	if !_character.item_manager.using and can_teleport:
		_character.item_manager.using = true
		_character.item_manager.reload_timer = GameConfig.get_value("items-uses", "reload_teleport")
		_teleport(_character)
		_character.item_manager.uses -= 1


func _teleport(_character):
	var layer = Game.get_target_map_layer_node()
	var spawn = layer.projectiles
	var poof1 = poof_effect.instantiate()
	poof1.spawnpos = _character.item_manager.global_position
	poof1.spawnrot = _character.global_rotation
	spawn.add_child(poof1)
	if _character.movement.facing > 0:
		_character.position.x += 512
	else:
		_character.position.x -= 512
	var poof2 = poof_effect.instantiate()
	poof2.spawnpos = _character.item_manager.global_position
	poof2.spawnrot = _character.global_rotation
	spawn.add_child(poof2)
	Jukebox.play_sound("teleport")
