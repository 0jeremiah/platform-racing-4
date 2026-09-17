extends StaticBody2D
class_name BlockScene

@onready var block_texture = $BlockTexture
@onready var teleport_colorin_texture = $BlockTexture/TeleportColorinTexture
@onready var frozen_texture = $BlockTexture/FrozenTexture
@onready var area_hitbox = $AreaHitbox
@onready var top_hitbox = $TopHitbox
@onready var bottom_hitbox = $BottomHitbox
@onready var left_hitbox = $LeftHitbox
@onready var right_hitbox = $RightHitbox

var id = ""
var settings = ConfigurableBlockSettings.new()
var location: String = ""
var tile_map_layer = null
var frozen: bool = false
var freeze_timer: float = 0.0
var bump_timer: float = 0.0
var bump_direction: Vector2 = Vector2(0, -1)


func init(new_id: String, new_settings: ConfigurableBlockSettings):
	if new_id in BlockManager._block_lookup:
		id = new_id
		settings = new_settings
		var which_layer = 0 if new_settings.matter_type == ConfigurableBlockSettings.SOLID else 1
		collision_layer = BlockManager._tile_set.get_physics_layer_collision_layer(which_layer)
		collision_mask = 0 | 1
		area_hitbox.disabled = false if new_settings.matter_type != ConfigurableBlockSettings.SOLID else true
		top_hitbox.disabled = false if new_settings.matter_type == ConfigurableBlockSettings.SOLID and new_settings.top.type != ConfigurableBlockSideSettings.INACTIVE else true
		bottom_hitbox.disabled = false if new_settings.matter_type == ConfigurableBlockSettings.SOLID and new_settings.bottom.type != ConfigurableBlockSideSettings.INACTIVE else true
		left_hitbox.disabled = false if new_settings.matter_type == ConfigurableBlockSettings.SOLID and new_settings.left.type != ConfigurableBlockSideSettings.INACTIVE else true
		right_hitbox.disabled = false if new_settings.matter_type == ConfigurableBlockSettings.SOLID and new_settings.right.type != ConfigurableBlockSideSettings.INACTIVE else true
		set_block_texture()


func _ready():
	var parent = get_parent()
	if parent and parent is ConfigurableTileMapLayer:
		var is_valid: bool = false
		location = str(int((position.x - Settings.tile_size_half.x) / Settings.tile_size.x)) + "," + str(int((position.y - Settings.tile_size_half.y) / Settings.tile_size.y))
		if location in parent.block_dict:
			parent.block_dict[location].node = self
			init(parent.block_dict[location].id, parent.block_dict[location].settings)
			name = location
			is_valid = true
		if !is_valid:
			queue_free()
		tile_map_layer = parent
		frozen_texture.texture = BlockManager.get_block_texture("16")


func _process(delta: float) -> void:
	#var camera = get_viewport().get_camera_2d()
	#var block_position = null if !camera else Vector2(((Vector2(Settings.tile_size) * Vector2(get_coords())) + Vector2(Settings.tile_size) / 2) * camera.zoom)
	#visible = true if camera and block_position and tile_map_layer.visible_block_rect.has_point(block_position) else false
	if frozen:
		if freeze_timer - delta > 0:
			freeze_timer -= delta
			frozen_texture.self_modulate.a = freeze_timer / 1.666
		else:
			freeze_timer = 0
			frozen = false
			frozen_texture.visible = false
	if bump_timer > 0:
		if bump_timer - delta > 0:
			bump_timer -= delta
		else:
			bump_timer = 0
	block_texture.position = block_texture.position.lerp(Vector2(((float(Settings.tile_size.x) / 2) * bump_direction.x) * (bump_timer / 0.5), ((float(Settings.tile_size.y) / 2) * bump_direction.y) * (bump_timer / 0.5)), delta * 30.0)


func get_coords() -> Vector2i:
	return Vector2i(int((position.x - Settings.tile_size_half.x) / Settings.tile_size.x), int((position.y - Settings.tile_size_half.y) / Settings.tile_size.y))


func set_block_texture():
	teleport_colorin_texture.visible = false
	block_texture.texture = BlockManager.get_block_texture(id)
	if settings.has_side_type(ConfigurableBlockSideSettings.TELEPORT):
		teleport_colorin_texture.texture = BlockManager.get_block_teleport_texture(id)
		teleport_colorin_texture.self_modulate = Color(settings.teleport_color)
		teleport_colorin_texture.visible = true


func freeze():
	freeze_timer = 1.666
	frozen = true
	frozen_texture.visible = true


func animate_bump(new_bump_direction: Vector2 = Vector2(0.0, -1.0)):
	bump_timer = 0.5
	bump_direction = new_bump_direction


func dull_out():
	modulate.r = 0.5
	modulate.g = 0.5
	modulate.b = 0.5


func undull_out():
	modulate.r = 1.0
	modulate.g = 1.0
	modulate.b = 1.0
