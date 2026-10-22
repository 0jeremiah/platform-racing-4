extends Control
class_name MapLayer

@onready var tile_map_layers_container = $TileMapLayersContainer
@onready var tile_map_layer = $TileMapLayersContainer/TileMapLayer
@onready var non_static_tile_map_layers = $TileMapLayersContainer/NonStaticTileMapLayers
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
	offset_transform_enabled = true
	offset_transform_visual_only = false
	tile_map_layers_container.offset_transform_enabled = true
	tile_map_layers_container.offset_transform_visual_only = false
	set_z_axis(z_axis)
	set_map_layer_rotation(tile_map_rotation)
	set_map_anchor(anchor)
	set_layer_z_index(layer_z_index)


#func _process(_delta: float) -> void:
	#update_map_layer_display()


func set_z_axis(p_z_axis: int) -> void:
	z_axis = p_z_axis
	offset_transform_scale = Vector2(get_layer_scale(), get_layer_scale())
	#update_map_layer_display()


func get_layer_scale() -> float:
	return float(z_axis) / 10.0


func set_map_layer_rotation(p_rotation: int) -> void:
	tile_map_rotation = p_rotation
	tile_map_layers_container.offset_transform_rotation = deg_to_rad(tile_map_rotation)
	#update_map_layer_display()


func set_map_anchor(p_anchor: Vector2) -> void:
	anchor = p_anchor
	tile_map_layers_container.offset_transform_pivot = anchor
	#update_map_layer_display()


func set_layer_name(new_layer_name: String) -> void:
	layer_name = new_layer_name


func set_layer_z_index(p_z_index: int) -> void:
	layer_z_index = p_z_index
	z_index = layer_z_index


func update_map_layer_display():
	var camera = get_viewport().get_camera_2d()
	if camera:
		offset_transform_position = camera.get_screen_center_position() - (camera.get_screen_center_position() * Vector2(get_layer_scale(), get_layer_scale()))
