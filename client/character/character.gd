class_name Character
extends CharacterBody2D
## Main player character with physics, items, and movement controls
##
## Handles all character physics, movement, animation, 
## item management and interaction with game tiles.

@onready var hitbox := $CharacterHitbox
@onready var light := $Light
@onready var camera := $Camera
@onready var particles := $Particles
@onready var low_area := $LowArea
@onready var high_area := $HighArea
@onready var item_manager := $ItemManager
@onready var ice := $Ice
@onready var display := $Display
@onready var item_holder_display := $Display/ItemHolder
@onready var sjaura := $SuperJumpAura
@onready var animations: AnimationPlayer = $Display/Animations

var active := false
var item: Node2D
var game: Node2D
var hat_array = [{"id": "2", "color": "FF0000", "epic_color": "FF0000"}, {"id": "2", "color": "00FF00", "epic_color": "00FF00"}, {"id": "2", "color": "0000FF", "epic_color": "0000FF"}]
var sun_particles = null
var moon_particles = null
var speed_particles = null
var invincibility_particles = null

# Component controllers
var stats: Stats = Stats.new()
var gravity: Gravity = Gravity.new()
var super_jump: SuperJump = SuperJump.new()
var camera_controller: CameraController
var lightbreak: LightbreakController
var movement: MovementController
var animation: AnimationController
var tile_interaction: TileInteractionController
var particle_controller: ParticleController
var control_vector: Vector2


func _ready() -> void:
	camera_controller = CameraController.new(camera)
	particle_controller = ParticleController.new(self)
	lightbreak = LightbreakController.new(light, sun_particles, moon_particles)
	movement = MovementController.new(ice)
	animation = AnimationController.new(display, sjaura)
	tile_interaction = TileInteractionController.new(self, low_area, high_area)
	tile_interaction.last_safe_position = Vector2(position)
	item_manager.init(self)
	display.set_hat_array(hat_array)
	display.set_head("2")
	display.set_body("2")
	display.set_feet("2")
	

func _physics_process(delta: float) -> void:
	if not active:
		return
	
	# Update hitbox based on crouch state and size
	if gravity.not_rotating:
		movement.is_crouching = tile_interaction.should_crouch(self)
		hitbox.run(self)
		low_area.position = hitbox.position
		low_area.get_child(0).shape.size = Vector2(hitbox.shape.size.x * 0.5, 1.0)
		low_area.get_child(0).position = Vector2(0.0, 0.0)
		high_area.position = Vector2(0.0, (-float(Settings.tile_size.y) * movement.size))
		high_area.get_child(0).shape.size = Vector2(1.0, 1.0)
		high_area.get_child(0).position = Vector2(0.0, 0.0)
	
	# Process gravity
	var gravity_value = 1.0
	if Game.game:
		gravity_value = Game.game.level_manager.gravity
	gravity.run(self, delta, gravity_value)
	
	# Update velocity from super jump
	if not movement.hurt and gravity.not_rotating():
		super_jump.run(self, delta)
	
	# Process item forces
	_process_item_forces()
	
	# Process movement
	velocity = movement.process(delta, self, stats, gravity, super_jump) * Vector2(tile_interaction.get_depth(), tile_interaction.get_depth())
	
	# Process lightbreak
	control_vector = Input.get_vector("left", "right", "up", "down")
	var lightbreak_velocity := lightbreak.process(delta, control_vector, self)
	if lightbreak_velocity != Vector2.ZERO:
		velocity = (lightbreak_velocity) * Vector2(tile_interaction.get_depth(), tile_interaction.get_depth())
	
	if gravity.not_rotating():
		movement.previous_velocity = movement.current_velocity
		if !movement.finished:
			move_and_slide()
			var collision = get_last_slide_collision()
			if collision:
				movement.current_velocity = velocity / Vector2(tile_interaction.get_depth(), tile_interaction.get_depth())
	
	# Interact with tiles
	tile_interaction.interact_with_incoporeal_tiles(self)
	var hit_something := tile_interaction.interact_with_solid_tiles(self, lightbreak)
	
	# End lightbreak if we hit something
	if hit_something and lightbreak.direction.length() > 0:
		lightbreak.end_lightbreak()
		modulate.a = 1
	
	# Prevent getting stuck in a block
	tile_interaction.inside_solid_blocks_check(self)
	
	# Item usage
	if !movement.finished:
		_process_items()
	
	# Update animations
	animation.process(self, movement, super_jump)
	
	# Check boundaries
	tile_interaction.check_out_of_bounds(self)
	
	# Update camera
	camera_controller.process(delta, position, rotation, lightbreak.is_active())


func _bump_tile_covering_high_area() -> void:
	var tiles: Array = tile_interaction.get_tiles_overlapping_area(self, high_area)
	if tiles.size() != 0:
		var tile = tiles[0]
		movement.attempting_bump = true
		if tile != movement.last_bumped_block:
			var tile_info = tile.tile_map_layer.get_block(tile.coords)
			if tile_info.node == null:
				return
			var direction = (global_position - tile_info.node.global_position).normalized()
			var normal := Vector2.ZERO
			if abs(direction.x) > abs(direction.y):
				normal = Vector2(sign(direction.x), 0)
			else:
				normal = Vector2(0, sign(direction.y))
			normal = normal.rotated(-rotation).normalized()
			var events: Array[String]
			if abs(normal.x) > abs(normal.y):
				if normal.x > 0:
					events.append("left")
				else:
					events.append("right")
			else:
				if normal.y > 0:
					events.append("bottom")
				else:
					events.append("top")
			events.append("bump")
			events.append("any_side")
			tile.tile_map_layer.trigger_tile_behaviors(self, tile.coords, events, normal)
			tile_interaction.maybe_update_last_bumped_block(self, tile.tile_map_layer, tile.coords)
	else:
		push_error("Character::bump_tile_covering_high_area - No tile covering high area")


func _process_item_forces() -> void:
	var item_force := Vector2.ZERO
	if item_manager.item:
		item_force = item_manager.force
	
	if item_force != Vector2.ZERO:
		var item_force_x: float = item_force.x * movement.facing
		var item_force_y: float = 0
		if !movement.is_crouching:
			item_force_y = item_force.y
		velocity += Vector2(item_force_x, item_force_y).rotated(rotation) * Vector2(tile_interaction.get_depth(), tile_interaction.get_depth())


func _process_items() -> void:
	# Use items
	if not movement.hurt and Input.is_action_pressed("item"):
		item_manager.try_to_use()
	
	# Check item state
	if not movement.hurt and item:
		item_manager.check_item()


func lose_hat() -> Dictionary:
	var hat_info = {"id": "", "color": "FFFFFF", "epic_color": "FFFFFF"}
	if hat_array.size() > 0:
		hat_info = hat_array.pop_back()
	display.set_hat_array(hat_array)
	return hat_info


func set_appearance(new_hat_array: Array, new_head_id: String, new_body_id: String, new_feet_id: String,
new_head_color: String = "FFFFFF", new_body_color: String = "FFFFFF", new_feet_color: String = "FFFFFF", new_head_epic_color: String = "FFFFFF",
new_body_epic_color: String = "FFFFFF", new_feet_epic_color: String = "FFFFFF"):
	display.set_hat_array(new_hat_array)
	display.set_head(new_head_id, new_head_color, new_head_epic_color)
	display.set_body(new_body_id, new_body_color, new_body_epic_color)
	display.set_feet(new_feet_id, new_feet_color, new_feet_epic_color)
