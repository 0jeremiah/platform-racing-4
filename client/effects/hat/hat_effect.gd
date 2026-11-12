extends RealEffect
class_name HatEffect

@onready var hat_graphic = $HatGraphic
@onready var hat_color_graphic = $HatGraphic/HatColor
@onready var hat_lines_graphic = $HatGraphic/HatLines
@onready var hat_epic_color_graphic = $HatGraphic/HatEpicColor
@onready var hat_misc1_graphic = $HatGraphic/HatMisc1
@onready var hat_misc2_graphic = $HatGraphic/HatMisc2
@onready var detect_player_area = $DetectPlayerArea

var wait_steps: int = 30
var tile_map_layer: ConfigurableTileMapLayer = null
var hat_id: String = "2"
var hat_color: String = "FFFFFF"
var hat_epic_color: String = "FFFFFF"
var hat_size: Vector2 = Vector2(0.65, 0.65)


func _ready() -> void:
	effect = self
	collision_layer = BlockManager._tile_set.get_physics_layer_collision_layer(BlockManager.solid_layer_id)
	collision_mask = BlockManager._tile_set.get_physics_layer_collision_mask(BlockManager.solid_layer_id)
	for player in Game.game.player_manager.player_array:
		add_collision_exception_with(player)
	detect_player_area.monitoring = false
	set_effect_area(detect_player_area)
	set_hat_texture()
	hat_graphic.scale = hat_size
	effect.linear_velocity.x = randf_range(-200.0, 200.0)
	effect.linear_velocity.y = randf_range(-200.0, 200.0)


func _process(_delta: float):
	if wait_steps > 0:
		wait_steps -= 1
	elif detect_player_area.monitoring == false:
		detect_player_area.monitoring = true
	if Game.game and Game.game.level_manager.level_layers.is_out_of_bounds(self):
		send_hat_to_start_position(self)


func set_hat_texture():
	var hat_textures = CharacterManager.get_part_textures(hat_id, "hat")
	hat_color_graphic.texture = hat_textures["color"]
	hat_lines_graphic.texture = hat_textures["lines"]
	hat_epic_color_graphic.texture = hat_textures["epic_color"]
	hat_misc1_graphic.texture = hat_textures["misc1"]
	hat_misc2_graphic.texture = hat_textures["misc2"]
	hat_color_graphic.self_modulate = Color(hat_color)
	hat_epic_color_graphic.self_modulate = Color(hat_epic_color)


func send_hat_to_start_position(hat_effect: HatEffect):
	var start_position = Game.game.level_manager.get_next_start_position()
	if tile_map_layer != null and hat_effect in tile_map_layer.map_layer.effects:
		tile_map_layer.map_layer.effects.remove_child(hat_effect)
		start_position.tile_map_layer.effects.add_child(hat_effect)
		start_position.tile_map_layer.get_block_center_position(start_position.coords)
	else:
		queue_free()


func touch_local_player(character: Character):
	# code for local player touching the hat goes here
	queue_free()
