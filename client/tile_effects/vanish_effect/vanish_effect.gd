extends Node2D
class_name VanishEffect

# Assumes AnimationPlayer's "vanish" and "appear" animations have the same length

@onready var sprite = $Sprite
@onready var area: Area2D = $Area
@onready var animation_player = $AnimationPlayer
@onready var invisibility_timer = $InvisibilityTimer

var tile_map_layer: TileMapLayer
var coords: Vector2i
var block_id: String
var source_id: int
var atlas_coords: Vector2i


func _ready() -> void:
	area.body_exited.connect(_on_body_exited)
	animation_player.animation_finished.connect(_on_animation_finished)
	invisibility_timer.timeout.connect(_on_timeout)


func init(_tile_map_layer: TileMapLayer, _coords: Vector2i, animation_duration: float, cooldown: float) -> void:
	
	tile_map_layer = _tile_map_layer
	coords = _coords
	source_id = tile_map_layer.get_cell_source_id(coords)
	atlas_coords = tile_map_layer.get_cell_atlas_coords(coords)
	block_id = tile_map_layer.get_cell_block_id(coords)
	
	sprite.texture = tile_map_layer.tile_set.get_source(source_id).texture
	sprite.region_enabled = true
	sprite.region_filter_clip_enabled = true
	sprite.region_rect = Rect2i(atlas_coords * Settings.tile_size, Settings.tile_size)
	
	# Set mask to detect character layer for the same depth
	var depth = Helpers.get_depth(tile_map_layer)
	var layer = Helpers.to_bitmask_32(depth * 2 - 1)
	area.collision_mask = layer
	
	if animation_duration > 0:
		animation_player.speed_scale = 1 / animation_duration
	else:
		animation_player.speed_scale = 0
	invisibility_timer.wait_time = cooldown
	
	tile_map_layer.set_cell_by_id(coords, block_id, ConfigurableBlock.INVISIBLE_ALT_ID)


func vanish_again() -> void:
	
	if !animation_player.is_playing():
		return
	
	if animation_player.assigned_animation != "appear":
		return
	
	var progress = animation_player.get_current_animation_position()
	
	# Edge case when the player touches a block right as it were going to appear
	if progress == 0:
		return
	
	var duration = animation_player.get_animation("appear").length
	
	animation_player.play("vanish")
	animation_player.seek(duration - progress)


func _try_to_appear() -> void:
	
	if animation_player.is_playing():
		return
	
	if !invisibility_timer.is_stopped():
		return
	
	for body in area.get_overlapping_bodies():
		if body is Character: # TODO: Ignore if wearing top hat
			return
	
	var current_block_id = tile_map_layer.get_cell_block_id(coords)
	if current_block_id == "":
		tile_map_layer.set_cell_by_id(coords, block_id, ConfigurableBlock.INVISIBLE_ALT_ID)
	animation_player.play("appear")


func _on_animation_finished(animation_name: StringName) -> void:
	match animation_name:
		"vanish":
			if vanish_still_exists():
				tile_map_layer.erase_cell(coords)
				invisibility_timer.start()
		"appear":
			if vanish_still_exists():
				tile_map_layer.set_cell_by_id(coords, block_id, ConfigurableBlock.VISIBLE_ALT_ID)
			queue_free()


func _on_timeout() -> void:
	_try_to_appear()


func _on_body_exited(_body) -> void:
	_try_to_appear()


func vanish_still_exists() -> bool:
	if tile_map_layer and coords:
		var current_block_id = tile_map_layer.get_cell_block_id(coords)
		if current_block_id:
			var current_source_id = tile_map_layer._block_lookup[current_block_id].source_id
			var current_atlas_coords = tile_map_layer._block_lookup[current_block_id].atlas_coords
			if current_source_id == source_id and current_atlas_coords == atlas_coords:
				return true
	return false
