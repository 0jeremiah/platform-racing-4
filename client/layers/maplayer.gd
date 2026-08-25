extends Parallax2D
class_name MapLayer

@onready var tile_map_layer_container = $TileMapLayerContainer
@onready var tile_map_layer = $TileMapLayerContainer/TileMapLayer
@onready var non_static_tile_map_layers = $TileMapLayerContainer/NonStaticTileMapLayers
@onready var players = $Players
@onready var enemies = $Enemies
@onready var projectiles = $Projectiles
@onready var effects = $Effects

var z_axis: int = 10
var tile_map_rotation: int = 0
var anchor: Vector2 = Vector2(0, 0)
var layer_name: String = ""
var layer_z_index: int = 10


func _ready() -> void:
	tile_map_layer.tile_set = BlockManager._tile_set
	tile_map_layer.map_layer = self
	z_as_relative = false
	set_z_axis(z_axis)
	set_map_layer_rotation(tile_map_rotation)
	set_anchor(anchor)
	set_layer_z_index(layer_z_index)


func _process(_delta: float) -> void:
	if Game.game:
		var character = Game.game.player_manager.get_character()
		if character.tile_interaction.character_depth == z_axis:
			tile_map_layer.collision_enabled = true
		else:
			tile_map_layer.collision_enabled = false


func set_z_axis(p_z_axis: int) -> void:
	z_axis = p_z_axis
	scroll_scale = Vector2(get_layer_scale(), get_layer_scale())
	scale = Vector2(get_layer_scale(), get_layer_scale())
	var camera = get_viewport().get_camera_2d()
	if camera:
		screen_offset = (get_viewport().get_visible_rect().size / 2) * scroll_scale


func get_layer_scale() -> float:
	return float(z_axis) / 10.0


func set_map_layer_rotation(p_rotation: int) -> void:
	tile_map_rotation = p_rotation
	tile_map_layer_container.rotation_degrees = tile_map_rotation


func set_anchor(p_anchor: Vector2) -> void:
	anchor = p_anchor
	tile_map_layer_container.pivot_offset = anchor


func set_layer_name(new_layer_name: String) -> void:
	layer_name = new_layer_name


func set_layer_z_index(p_z_index: int) -> void:
	layer_z_index = p_z_index
	z_index = layer_z_index
