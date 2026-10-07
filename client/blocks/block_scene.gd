extends StaticBody2D
class_name BlockScene

@onready var block_texture = $BlockTexture
@onready var teleport_colorin_texture = $BlockTexture/TeleportColorinTexture
@onready var dull_square_graphic = $BlockTexture/TeleportColorinTexture/DullSquareGraphic
@onready var frozen_texture = $BlockTexture/FrozenTexture
@onready var top_hitbox = $TopHitbox
@onready var bottom_hitbox = $BottomHitbox
@onready var left_hitbox = $LeftHitbox
@onready var right_hitbox = $RightHitbox
@onready var area_hitbox = $AreaHitbox
@onready var block_detection_area = $BlockDetectionArea

var laser_bullet = preload("res://item_effects/laser_bullet.tscn")
var active: bool = true
var id = ""
var settings = ConfigurableBlockSettings.new()
var tile_map_layer = null
var initialized: bool = false
var location: String = ""
var frozen: bool = false
var fade_mode: String = "idle"
var fade_duration: float = 0.3
var fade_cooldown: float = 2.0
var fade_timer: float = 0.0
var freeze_timer: float = 0.0
var teleport_throttle_timer: float = 0.0
var bump_timer: float = 0.0
var bump_direction: Vector2 = Vector2(0, -1)
var top_hitbox_enabled: bool = true
var bottom_hitbox_enabled: bool = true
var left_hitbox_enabled: bool = true
var right_hitbox_enabled: bool = true
var area_hitbox_enabled: bool = true
var block_collision_layer: int = 0
var just_hidden: bool = false
var random_move_pattern: String  = ""
var is_change_block: bool = false
var register_change_block: bool = true
var move_block_active_mode: bool = false
var move_block_move_command: String = ""
var can_move = true
var move_cooldown_timer: float = 0
var origin_coords: Vector2i = Vector2i(0, 0)
var sniper_cooldown: float = 1.0
var sniper_timer: float = sniper_cooldown


func init(new_id: String, new_settings: ConfigurableBlockSettings):
	location = str(int((position.x - Settings.tile_size_half.x) / Settings.tile_size.x)) + "," + str(int((position.y - Settings.tile_size_half.y) / Settings.tile_size.y))
	if location in tile_map_layer.block_dict:
		if new_id in BlockManager._block_lookup:
			id = new_id
			settings = new_settings
			location = str(int((position.x - Settings.tile_size_half.x) / Settings.tile_size.x)) + "," + str(int((position.y - Settings.tile_size_half.y) / Settings.tile_size.y))
			tile_map_layer.block_dict[location].id = id
			tile_map_layer.block_dict[location].settings = settings
			tile_map_layer.block_dict[location].node = self
			active = true if settings.matter_type == ConfigurableBlockSettings.SOLID else false
			block_collision_layer = BlockManager.solid_layer_id if settings.matter_type == ConfigurableBlockSettings.SOLID else BlockManager.non_solid_layer_id
			collision_layer = BlockManager._tile_set.get_physics_layer_collision_layer(block_collision_layer)
			collision_mask = BlockManager._tile_set.get_physics_layer_collision_layer(BlockManager.solid_layer_id) | BlockManager._tile_set.get_physics_layer_collision_layer(BlockManager.non_solid_layer_id)
			block_detection_area.collision_layer = collision_layer
			block_detection_area.collision_mask = collision_mask
			top_hitbox_enabled = true if settings.matter_type == ConfigurableBlockSettings.SOLID and settings.top.type != ConfigurableBlockSideSettings.INACTIVE else false
			bottom_hitbox_enabled = true if settings.matter_type == ConfigurableBlockSettings.SOLID and settings.bottom.type != ConfigurableBlockSideSettings.INACTIVE else false
			left_hitbox_enabled = true if settings.matter_type == ConfigurableBlockSettings.SOLID and settings.left.type != ConfigurableBlockSideSettings.INACTIVE else false
			right_hitbox_enabled = true if settings.matter_type == ConfigurableBlockSettings.SOLID and settings.right.type != ConfigurableBlockSideSettings.INACTIVE else false
			area_hitbox_enabled = true if settings.matter_type != ConfigurableBlockSettings.SOLID else false
			fade_mode = "hidden" if settings.has_side_type(ConfigurableBlockSideSettings.APPEAR) else "idle"
			initialized = true
			register_block_type()
			set_block_texture()
	else:
		queue_free()


func register_block_type():
	if Game.game:
		if settings.block_type == ConfigurableBlockSettings.START_POSITION:
			Game.game.level_manager.register_start_block(self)
		if settings.block_type == ConfigurableBlockSettings.MOVE:
			Game.game.level_manager.register_move_block(self)
		if (settings.block_type == ConfigurableBlockSettings.CHANGE or is_change_block) and register_change_block:
			is_change_block = true
			Game.game.level_manager.register_change_block(self)
		if settings.has_side_type(ConfigurableBlockSideSettings.FINISH):
			Game.game.level_manager.register_finish_block(self)
		if settings.has_side_type(ConfigurableBlockSideSettings.TELEPORT):
			Game.game.level_manager.register_teleport_block(self)


func unregister_block_type(unregister_change: bool = true):
	if initialized and Game.game:
		if settings.block_type == ConfigurableBlockSettings.MOVE:
			Game.game.level_manager.remove_move_block(self)
		if settings.block_type == ConfigurableBlockSettings.START_POSITION:
			Game.game.level_manager.remove_start_block(self)
		if settings.has_side_type(ConfigurableBlockSideSettings.FINISH):
			Game.game.level_manager.remove_finish_block(self)
		if settings.has_side_type(ConfigurableBlockSideSettings.TELEPORT):
			Game.game.level_manager.remove_teleport_block(self)
		register_change_block = unregister_change
		if is_change_block and unregister_change:
			Game.game.level_manager.remove_change_block(self)


func _ready():
	var parent = get_parent()
	if parent and parent is ConfigurableTileMapLayer:
		var is_valid: bool = false
		location = str(int((position.x - Settings.tile_size_half.x) / Settings.tile_size.x)) + "," + str(int((position.y - Settings.tile_size_half.y) / Settings.tile_size.y))
		if location in parent.block_dict:
			tile_map_layer = parent
			init(parent.block_dict[location].id, parent.block_dict[location].settings)
			name = location
			is_valid = true
		if !is_valid:
			queue_free()
		frozen_texture.texture = BlockManager.get_block_texture("16")


func _process(delta: float) -> void:
	if Game.game:
		if !(top_hitbox_enabled and tile_map_layer.collision_enabled and (active or (!active and settings.top.type == ConfigurableBlockSideSettings.APPEAR))) != top_hitbox.disabled:
			top_hitbox.disabled = !(top_hitbox_enabled and tile_map_layer.collision_enabled and (active or (!active and settings.top.type == ConfigurableBlockSideSettings.APPEAR)))
		if !(bottom_hitbox_enabled and tile_map_layer.collision_enabled and (active or (!active and settings.bottom.type == ConfigurableBlockSideSettings.APPEAR))) != bottom_hitbox.disabled:
			bottom_hitbox.disabled = !(bottom_hitbox_enabled and tile_map_layer.collision_enabled and (active or (!active and settings.top.type == ConfigurableBlockSideSettings.APPEAR)))
		if !(left_hitbox_enabled and tile_map_layer.collision_enabled and (active or (!active and settings.left.type == ConfigurableBlockSideSettings.APPEAR))) != left_hitbox.disabled:
			left_hitbox.disabled = !(left_hitbox_enabled and tile_map_layer.collision_enabled and (active or (!active and settings.top.type == ConfigurableBlockSideSettings.APPEAR)))
		if !(right_hitbox_enabled and tile_map_layer.collision_enabled and (active or (!active and settings.right.type == ConfigurableBlockSideSettings.APPEAR))) != right_hitbox.disabled:
			right_hitbox.disabled = !(right_hitbox_enabled and tile_map_layer.collision_enabled and (active or (!active and settings.top.type == ConfigurableBlockSideSettings.APPEAR)))
		if !(area_hitbox_enabled and tile_map_layer.collision_enabled and settings.matter_type != ConfigurableBlockSettings.SOLID) != area_hitbox.disabled:
			area_hitbox.disabled = !(area_hitbox_enabled and tile_map_layer.collision_enabled and settings.matter_type != ConfigurableBlockSettings.SOLID)
	if frozen:
		if freeze_timer - delta > 0:
			freeze_timer -= delta
			frozen_texture.self_modulate.a = freeze_timer / 1.666
		else:
			freeze_timer = 0
			frozen = false
			frozen_texture.visible = false
	if move_cooldown_timer > 0:
		if move_cooldown_timer - delta > 0:
			move_cooldown_timer -= delta
		else:
			can_move = true
	if teleport_throttle_timer > 0:
		if teleport_throttle_timer - delta > 0:
			teleport_throttle_timer -= delta
			dull_square_graphic.size.y = Settings.tile_size.y * (teleport_throttle_timer / settings.teleport_throttle)
		else:
			teleport_throttle_timer = 0.0
			dull_square_graphic.visible = false
	if bump_timer > 0:
		if bump_timer - delta > 0:
			bump_timer -= delta
		else:
			bump_timer = 0
	if just_hidden:
		collision_layer = BlockManager._tile_set.get_physics_layer_collision_layer(block_collision_layer)
		just_hidden = false
	if Game.game:
		if sniper_timer - delta > 0:
			sniper_timer -= delta
		else:
			snipe()
			sniper_timer = sniper_cooldown
		if !(fade_mode == "idle" or fade_mode == "hidden") or fade_timer > 0:
			if fade_timer - delta > 0:
				fade_timer -= delta
			elif (fade_mode == "vanish" or fade_mode == "vanish_no_revert") or (fade_mode == "appear" or fade_mode == "appear_no_revert"):
				if fade_mode == "vanish" or fade_mode == "vanish_no_revert":
					collision_layer = 0
					just_hidden = true
					active = false
					if fade_mode == "vanish_no_revert":
						fade_mode = "hidden"
					elif fade_mode == "vanish":
						fade_mode = "vanish_cooldown"
						fade_timer = fade_cooldown
				elif fade_mode == "appear" or fade_mode == "appear_no_revert":
					if fade_mode == "appear_no_revert":
						fade_mode = "idle"
					elif fade_mode == "appear":
						fade_mode = "appear_cooldown"
						fade_timer = fade_cooldown
			elif fade_mode == "vanish_cooldown" or fade_mode == "appear_cooldown":
				if !player_is_in_block(true):
					if fade_mode == "vanish_cooldown":
						fade_mode = "reverse_vanish"
						collision_layer = BlockManager._tile_set.get_physics_layer_collision_layer(block_collision_layer)
						active = true
					elif fade_mode == "appear_cooldown":
						fade_mode = "reverse_appear"
					fade_timer = fade_duration
				else:
					fade_timer = 0.0 if fade_cooldown == 0.0 else fade_cooldown / 2
					if fade_mode == "vanish" or fade_mode == "vanish_no_revert":
						collision_layer = 0
						just_hidden = true
						active = false
						if fade_mode == "vanish_no_revert":
							fade_mode = "idle"
						elif fade_mode == "vanish":
							fade_mode = "vanish_cooldown"
							fade_timer = 0.0 if fade_cooldown == 0.0 else fade_cooldown / 2
			elif fade_mode == "reverse_vanish" or fade_mode == "reverse_appear":
				fade_mode = "hidden" if fade_mode == "reverse_appear" else "idle"
				fade_timer = 0.0
		if ((fade_mode == "vanish" or fade_mode == "vanish_no_revert") or fade_mode == "reverse_appear") and fade_duration != 0.0:
			block_texture.modulate.a = fade_timer / fade_duration
		elif ((fade_mode == "appear" or fade_mode == "appear_no_revert") or fade_mode == "reverse_vanish") and fade_duration != 0.0:
			block_texture.modulate.a = 1.0 - (fade_timer / fade_duration)
		elif (fade_mode == "vanish_cooldown" or fade_mode == "appear_cooldown") and fade_cooldown != 0.0:
			block_texture.modulate.a = 1.0 if fade_mode == "appear_cooldown" else 0.0
		else:
			block_texture.modulate.a = 0.0 if fade_mode == "hidden" else 1.0
	else:
		block_texture.modulate.a = 1.0
	block_texture.position = Vector2(((float(Settings.tile_size.x) / 2) * bump_direction.x) * (bump_timer / 0.5), ((float(Settings.tile_size.y) / 2) * bump_direction.y) * (bump_timer / 0.5))


func get_coords() -> Vector2i:
	return Vector2i(int((position.x - Settings.tile_size_half.x) / Settings.tile_size.x), int((position.y - Settings.tile_size_half.y) / Settings.tile_size.y))


func set_block_texture():
	teleport_colorin_texture.visible = false
	block_texture.texture = BlockManager.get_block_texture(id)
	if settings.has_side_type(ConfigurableBlockSideSettings.TELEPORT):
		teleport_colorin_texture.texture = BlockManager.get_block_teleport_texture(id)
		teleport_colorin_texture.self_modulate = Color(settings.teleport_color)
		teleport_colorin_texture.visible = true


func morph_block_type(new_id: String, new_settings: ConfigurableBlockSettings):
	unregister_block_type(false)
	init(new_id, new_settings)
	undull_out()


func freeze():
	freeze_timer = 1.666
	frozen = true
	frozen_texture.visible = true


func vanish(new_fade_duration: float, new_fade_cooldown: float, revert: bool = true):
	if fade_mode == "idle" or fade_mode == "reverse_vanish":
		var percentage = 0.0 if fade_duration == 0.0 else 1.0 - (fade_timer / new_fade_duration)
		if !revert:
			fade_mode = "vanish_no_revert"
		else:
			fade_mode = "vanish"
		fade_duration = new_fade_duration
		fade_cooldown = new_fade_cooldown
		fade_timer = fade_duration * percentage


func appear(new_fade_duration: float, new_fade_cooldown: float, revert: bool = true):
	if fade_mode == "idle" or fade_mode == "hidden" or fade_mode == "reverse_appear":
		var percentage = 0.0 if fade_duration == 0.0 else 1.0 - (fade_timer / new_fade_duration)
		if !revert:
			fade_mode = "appear_no_revert"
		else:
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


func throttle_teleport():
	teleport_throttle_timer = settings.teleport_throttle
	dull_square_graphic.size = Vector2(float(Settings.tile_size.x), float(Settings.tile_size.y))
	dull_square_graphic.visible = true


func assign_move_block_command(param_1: String):
	move_block_active_mode = true
	move_block_move_command = param_1


func execute_move_block_command() -> bool:
	var move_command: String = ""
	var moved: bool = false
	if move_block_active_mode:
		move_block_active_mode = false
		can_move = true
		move_command = move_block_move_command
		if move_command == "u":
			moved = move("top", false)
		elif move_command == "d":
			moved = move("bottom", false)
		elif move_command == "r":
			moved = move("right", false)
		elif move_command == "l":
			moved = move("left", false)
		elif move_command == "@":
			var current_coords = get_coords()
			if current_coords != origin_coords:
				var block_at_origin_coords_info = tile_map_layer.get_block(origin_coords)
				if block_at_origin_coords_info.id != "" and block_at_origin_coords_info.node != null and block_at_origin_coords_info.node.move_block_active_mode:
					block_at_origin_coords_info.execute_move_block_command()
				tile_map_layer.move_block(current_coords, origin_coords)
				moved = true
	return moved


func move(direction: String, param_2: bool = true) -> bool:
	var move_direction = Vector2i(0, 0)
	var side_name: String = ""
	var moved: bool = false
	if can_move:
		if direction == "top":
			move_direction = Vector2i.UP
			side_name = "bottom"
		elif direction == "bottom":
			move_direction = Vector2i.DOWN
			side_name = "top"
		elif direction == "left":
			move_direction = Vector2i.LEFT
			side_name = "right"
		elif direction == "right":
			move_direction = Vector2i.RIGHT
			side_name = "left"
		if move_direction != Vector2i(0, 0) and side_name != "":
			var my_coords = get_coords()
			var adjacent_coords = my_coords + move_direction
			if adjacent_coords != my_coords:
				var block_info = tile_map_layer.get_block(adjacent_coords)
				if block_info.id == "":
					tile_map_layer.move_block(my_coords, adjacent_coords)
					moved = true
				else:
					var moved_adjacent_block: bool = false
					var block_node = block_info.node
					if block_node and block_info.node.move_block_active_mode:
						moved_adjacent_block = block_info.node.execute_move_block_command()
					else:
						var block_side_settings = block_info.settings.get(side_name)
						if block_side_settings and block_side_settings.type == ConfigurableBlockSideSettings.PUSH:
							moved_adjacent_block = block_node.move(direction)
					if moved_adjacent_block:
						tile_map_layer.move_block(my_coords, adjacent_coords)
						moved = true
	if moved and param_2:
		can_move = false
		move_cooldown_timer = 0.033
	return moved


func snipe():
	if settings.top.type == ConfigurableBlockSideSettings.SNIPER or settings.any_side.type == ConfigurableBlockSideSettings.SNIPER:
		tile_map_layer.shoot_laser(position, deg_to_rad(270.0), false, self)
		Jukebox.play_sound("laser")
	if settings.bottom.type == ConfigurableBlockSideSettings.SNIPER or settings.any_side.type == ConfigurableBlockSideSettings.SNIPER:
		tile_map_layer.shoot_laser(position, deg_to_rad(90.0), false, self)
		Jukebox.play_sound("laser")
	if settings.left.type == ConfigurableBlockSideSettings.SNIPER or settings.any_side.type == ConfigurableBlockSideSettings.SNIPER:
		tile_map_layer.shoot_laser(position, deg_to_rad(180.0), false, self)
		Jukebox.play_sound("laser")
	if settings.right.type == ConfigurableBlockSideSettings.SNIPER or settings.any_side.type == ConfigurableBlockSideSettings.SNIPER:
		tile_map_layer.shoot_laser(position, 0.0, false, self)
		Jukebox.play_sound("laser")


func player_is_in_block(check_collision: bool = false) -> bool:
	if check_collision:
		var collision = move_and_collide(Vector2(0.0, 0.0), true)
		if collision and collision.get_collider() is Character:
			return true
	var overlapping_bodies = block_detection_area.get_overlapping_bodies()
	for overlapping_body in overlapping_bodies:
		if overlapping_body is Character:
			return true
	return false
