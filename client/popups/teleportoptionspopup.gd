extends Control

signal teleport_color_changed

@onready var teleport_base = $TeleportBlock/TeleportBase
@onready var teleport_color = $TeleportBlock/TeleportColor
@onready var color_button = $ColorButton

var teleport_base_texture: AtlasTexture
var teleport_color_texture: AtlasTexture
var color: Color = Color("ff7f50")


func init(new_color: Color, new_atlas_texture: Texture2D, new_teleport_base_rect2: Rect2, new_teleport_color_rect2: Rect2):
	color = new_color
	color_button.set_color(color)
	teleport_color.self_modulate = color
	teleport_base.texture.atlas = new_atlas_texture
	teleport_color.texture.atlas = new_atlas_texture
	teleport_base.texture.region = new_teleport_base_rect2
	teleport_color.texture.region = new_teleport_color_rect2


func _ready() -> void:
	color_button.connect("colorbutton_color_changed", change_color)
	color_button.spawn_x = color_button.size.x
	teleport_color.self_modulate = color


func change_color(new_color: Color):
	color = new_color
	teleport_color.self_modulate = color
	emit_signal("teleport_color_changed", color)
