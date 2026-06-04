class_name Character
extends CharacterBody2D
## Main player character with physics, items, and movement controls
##
## Handles all character physics, movement, animation, 
## item management and interaction with game tiles.

signal position_changed(x: float, y: float)
signal increase_time(new_timer: float)

@onready var hitbox := $CharacterHitbox
@onready var light := $Light
@onready var camera := $Camera
@onready var particles := $Particles
@onready var low_area := $LowArea
@onready var high_area := $HighArea
@onready var item_manager := $ItemManager
@onready var ice := $Ice
@onready var invincibility := $Invincibility
@onready var display := $Display
@onready var item_holder_display := $Display/ItemHolder
@onready var sjaura := $SuperJumpAura
@onready var animations: AnimationPlayer = $Display/Animations

var active := false
var item: Node2D
var game: Node2D
var tiles: Tiles
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
	

func _physics_process(delta: float) -> void:
	if not active:
		return
	
	# Update hitbox based on crouch state and size
	if gravity.not_rotating:
		movement.is_crouching = tile_interaction.should_crouch(self)
		hitbox.run(self)
		low_area.scale = Vector2(movement.size, movement.size)
		high_area.scale = Vector2(movement.size, movement.size)
	
	# Process gravity
	gravity.run(self, delta)
	
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
	
	# Interact with tiles
	tile_interaction.interact_with_incoporeal_tiles(self)
	var hit_something := tile_interaction.interact_with_solid_tiles(self, lightbreak)
	
	# End lightbreak if we hit something
	if hit_something and lightbreak.direction.length() > 0:
		lightbreak.end_lightbreak()
		modulate.a = 1
	
	# Item usage
	if !movement.finished:
		_process_items()
	
	# Update camera
	camera_controller.process(delta, position, rotation, lightbreak.is_active())
	
	# Update animations
	scale = Vector2(movement.size, movement.size)
	animation.process(self, movement, super_jump)
	
	# Check boundaries
	tile_interaction.check_out_of_bounds(self)


func _bump_tile_covering_high_area() -> void:
	var tiles: Array = tile_interaction.get_tiles_overlapping_area(high_area)
	
	if tiles.size() != 0:
		var tile = tiles[0]
	
		movement.attempting_bump = true
		if tile != movement.last_bumped_block:
			BlockManager._blocks[tile.block_id].on("bottom", self, tile.tile_map_layer, tile.coords)
			BlockManager._blocks[tile.block_id].on("any_side", self, tile.tile_map_layer, tile.coords)
			BlockManager._blocks[tile.block_id].on("bump", self, tile.tile_map_layer, tile.coords)
			movement.last_bumped_block = tile
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
