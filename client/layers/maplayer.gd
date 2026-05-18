extends Parallax2D
class_name MapLayer

@onready var tile_map_layer_container = $TileMapLayerContainer
@onready var tile_map_layer = $TileMapLayerContainer/TileMapLayer
@onready var non_static_tile_map_layers = $TileMapLayerContainer/NonStaticTileMapLayers
@onready var players = $Players
@onready var enemies = $Enemies
@onready var projectiles = $Projectiles
@onready var effects = $Effects

const TILEATLAS = preload("res://tiles/tileatlas.png")

var z_axis: int = 10
var tile_map_rotation: int = 0
var anchor: Vector2 = Vector2(0, 0)
var layer_name: String = ""


func _ready() -> void:
	tile_map_layer.tile_set = BlockManager._tile_set
	tile_map_layer.map_layer = self


func init() -> void:
	set_z_axis(z_axis)
	set_map_layer_rotation(tile_map_rotation)
	set_anchor(anchor)


func set_z_axis(p_z_axis: int) -> void:
	z_axis = p_z_axis
	
	var tile_set = tile_map_layer.tile_set
	if tile_set:
		tile_set.set_physics_layer_collision_layer(0, Helpers.to_bitmask_32((z_axis * 2) - 1))
		tile_set.set_physics_layer_collision_mask(0, Helpers.to_bitmask_32((z_axis * 2) - 1))
		tile_set.set_physics_layer_collision_layer(1, Helpers.to_bitmask_32(z_axis * 2))
		tile_set.set_physics_layer_collision_mask(1, Helpers.to_bitmask_32(z_axis * 2))
	
	var z_axis_compat = float(z_axis)
	var base_scale = z_axis_compat / 10.0
	scroll_scale = Vector2(base_scale, base_scale)
	scale = Vector2(base_scale, base_scale)
	z_index = z_axis


func get_layer_scale() -> float:
	return float(z_axis) / 10.0


func set_map_layer_rotation(p_rotation: int) -> void:
	tile_map_rotation = p_rotation
	tile_map_layer_container.rotation_degrees = tile_map_rotation


func set_anchor(p_anchor: Vector2) -> void:
	anchor = p_anchor
	tile_map_layer_container.pivot_offset = anchor
