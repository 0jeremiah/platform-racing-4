extends StaticBody2D
class_name BlockScene

@onready var block_texture = $BlockTexture
@onready var teleport_colorin_texture = $BlockTexture/TeleportColorinTexture
@onready var frozen_texture = $BlockTexture/FrozenTexture
@onready var top_hitbox = $TopHitbox
@onready var bottom_hitbox = $BottomHitbox
@onready var left_hitbox = $LeftHitbox
@onready var right_hitbox = $RightHitbox
@onready var area_hitbox = $AreaHitbox
@onready var block_detection_area = $BlockDetectionArea

var active: bool = true
var id = ""
var settings = ConfigurableBlockSettings.new()
var location: String = ""
var tile_map_layer = null
var frozen: bool = false
var can_appear: bool = false
var fade_mode: String = "idle"
var fade_duration: float = 0.3
var fade_cooldown: float = 2.0
var fade_timer: float = 0.0
var freeze_timer: float = 0.0
var bump_timer: float = 0.0
var bump_direction: Vector2 = Vector2(0, -1)
var top_hitbox_enabled: bool = true
var bottom_hitbox_enabled: bool = true
var left_hitbox_enabled: bool = true
var right_hitbox_enabled: bool = true
var area_hitbox_enabled: bool = true


func init(new_id: String, new_settings: ConfigurableBlockSettings):
	if new_id in BlockManager._block_lookup:
		id = new_id
		settings = new_settings
		active = true if settings.matter_type != ConfigurableBlockSettings.SOLID else false
		var which_layer = 0 if settings.matter_type == ConfigurableBlockSettings.SOLID else 1
		collision_layer = BlockManager._tile_set.get_physics_layer_collision_layer(which_layer)
		collision_mask = 0 | 1
		block_detection_area.collision_layer = collision_layer
		block_detection_area.collision_mask = collision_mask
		top_hitbox_enabled = true if settings.matter_type == ConfigurableBlockSettings.SOLID and settings.top.type != ConfigurableBlockSideSettings.INACTIVE else false
		bottom_hitbox_enabled = true if settings.matter_type == ConfigurableBlockSettings.SOLID and settings.bottom.type != ConfigurableBlockSideSettings.INACTIVE else false
		left_hitbox_enabled = true if settings.matter_type == ConfigurableBlockSettings.SOLID and settings.left.type != ConfigurableBlockSideSettings.INACTIVE else false
		right_hitbox_enabled = true if settings.matter_type == ConfigurableBlockSettings.SOLID and settings.right.type != ConfigurableBlockSideSettings.INACTIVE else false
		area_hitbox_enabled = true if settings.matter_type != ConfigurableBlockSettings.SOLID else false
		can_appear = settings.has_side_type(ConfigurableBlockSideSettings.APPEAR)
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
	if Game.game:
		if !(top_hitbox_enabled and tile_map_layer.collision_enabled and (fade_mode != "vanish_cooldown" or (fade_mode == "vanish_cooldown" and settings.top.type == ConfigurableBlockSideSettings.APPEAR))) != top_hitbox.disabled:
			top_hitbox.disabled = !(top_hitbox_enabled and tile_map_layer.collision_enabled and (fade_mode != "vanish_cooldown" or (fade_mode == "vanish_cooldown" and settings.top.type == ConfigurableBlockSideSettings.APPEAR)))
		if !(bottom_hitbox_enabled and tile_map_layer.collision_enabled and (fade_mode != "vanish_cooldown" or (fade_mode == "vanish_cooldown" and settings.bottom.type == ConfigurableBlockSideSettings.APPEAR))) != bottom_hitbox.disabled:
			bottom_hitbox.disabled = !(bottom_hitbox_enabled and tile_map_layer.collision_enabled and (fade_mode != "vanish_cooldown" or (fade_mode == "vanish_cooldown" and settings.top.type == ConfigurableBlockSideSettings.APPEAR)))
		if !(left_hitbox_enabled and tile_map_layer.collision_enabled and (fade_mode != "vanish_cooldown" or (fade_mode == "vanish_cooldown" and settings.left.type == ConfigurableBlockSideSettings.APPEAR))) != left_hitbox.disabled:
			left_hitbox.disabled = !(left_hitbox_enabled and tile_map_layer.collision_enabled and (fade_mode != "vanish_cooldown" or (fade_mode == "vanish_cooldown" and settings.top.type == ConfigurableBlockSideSettings.APPEAR)))
		if !(right_hitbox_enabled and tile_map_layer.collision_enabled and (fade_mode != "vanish_cooldown" or (fade_mode == "vanish_cooldown" and settings.right.type == ConfigurableBlockSideSettings.APPEAR))) != right_hitbox.disabled:
			right_hitbox.disabled = !(right_hitbox_enabled and tile_map_layer.collision_enabled and (fade_mode != "vanish_cooldown" or (fade_mode == "vanish_cooldown" and settings.top.type == ConfigurableBlockSideSettings.APPEAR)))
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
	if fade_mode != "idle" or fade_timer > 0:
		if fade_timer - delta > 0:
			fade_timer -= delta
		elif fade_mode == "vanish" or fade_mode == "appear":
			if fade_mode == "vanish":
				fade_mode = "vanish_cooldown"
			elif fade_mode == "appear":
				fade_mode = "appear_cooldown"
			fade_timer = fade_cooldown
			active = false
		elif fade_mode == "vanish_cooldown" or fade_mode == "appear_cooldown":
			if !player_is_in_block():
				if fade_mode == "vanish_cooldown":
					fade_mode = "reverse_vanish"
				elif fade_mode == "appear_cooldown":
					fade_mode = "reverse_appear"
				fade_timer = fade_duration
				active = true
			else:
				fade_timer = 0.0 if fade_cooldown == 0.0 else fade_cooldown / 2
				active = false
		elif fade_mode == "reverse_vanish" or fade_mode == "reverse_appear":
			fade_mode = "idle"
			fade_timer = 0.0
			active = true
	if (fade_mode == "vanish" or fade_mode == "reverse_appear") and fade_duration != 0.0:
		block_texture.modulate.a = fade_timer / fade_duration
	elif (fade_mode == "appear" or fade_mode == "reverse_vanish") and fade_duration != 0.0:
		block_texture.modulate.a = 1.0 - (fade_timer / fade_duration)
	elif (fade_mode == "vanish_cooldown" or fade_mode == "appear_cooldown") and fade_cooldown != 0.0:
		block_texture.modulate.a = 1.0 if can_appear else 0.0
	else:
		block_texture.modulate.a = 0.0 if can_appear else 1.0
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


func vanish(new_fade_duration: float, new_fade_cooldown: float):
	if fade_mode != "vanish":
		var percentage = 0.0 if fade_duration == 0.0 else 1.0 - (fade_timer / new_fade_duration)
		fade_mode = "vanish"
		fade_duration = new_fade_duration
		fade_cooldown = new_fade_cooldown
		fade_timer = fade_duration * percentage


func appear(new_fade_duration: float, new_fade_cooldown: float):
	if fade_mode != "appear":
		var percentage = 0.0 if fade_duration == 0.0 else 1.0 - (fade_timer / new_fade_duration)
		fade_mode = "appear"
		fade_duration = new_fade_duration
		fade_cooldown = new_fade_cooldown
		fade_timer = fade_duration * percentage


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


func player_is_in_block() -> bool:
	var overlapping_bodies = block_detection_area.get_overlapping_bodies()
	for overlapping_body in overlapping_bodies:
		if overlapping_body is Character:
			return true
	return false
