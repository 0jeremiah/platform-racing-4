extends Node2D

@onready var block_icon = $BlockIcon
@onready var block_light_mask = $BlockLightMask
@onready var animtimer = $AnimationTimer
@onready var animations: AnimationPlayer = $Animations

var block_id: String = ""
var coords: Vector2i = Vector2i(0, 0)
var tile_map_layer: TileMapLayer


func _ready():
	block_icon.texture = BlockManager.get_block_texture(block_id)
	block_light_mask.texture = BlockManager.get_block_texture(block_id)
	animtimer.connect("timeout", _place_block)
	animtimer.start()
	animations.play("spawn")
	Jukebox.play_sound("mineappear")


func init(_tile_map_layer: ConfigurableTileMapLayer, _coords: Vector2i, _block_id: String):
	tile_map_layer = _tile_map_layer
	coords = _coords
	block_id = _block_id


func _place_block():
	if tile_map_layer:
		tile_map_layer.add_block(coords, block_id)
	queue_free()
