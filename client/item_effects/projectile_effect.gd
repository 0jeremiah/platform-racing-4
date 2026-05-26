extends Node
class_name ProjectileEffect
## Same thing as TileCollisionDetector except designed specifically for projectiles.

var projectile: PhysicsBody2D
var from_player: Character = null
var projectile_velocity: Vector2 = Vector2(4800.0, 0.0)
var hit_velocity: Vector2 = Vector2(0.0, 0.0)
var life: float = 100.0


func set_projectile_node(projectile_node: PhysicsBody2D) -> void:
	projectile = projectile_node
	if projectile is RigidBody2D:
		_setup_rigidbody_signals()


func _setup_rigidbody_signals() -> void:
	var rigid_body := projectile as RigidBody2D
	rigid_body.contact_monitor = true
	rigid_body.max_contacts_reported = 10
	rigid_body.body_shape_entered.connect(_on_body_shape_entered)


func _physics_process(_delta: float) -> void:
	# For CharacterBody2D, detect collisions using get_last_slide_collision
	if projectile is CharacterBody2D:
		_detect_character_body_collisions()


func _process(delta: float) -> void:
	if life - delta > 0:
		life -= delta
	else:
		queue_free()


func set_projectile(projectile_node: PhysicsBody2D, _from_player: Character, _life: float, _projectile_velocity: Vector2, _hit_velocity: Vector2):
	set_projectile_node(projectile_node)
	from_player = _from_player
	life = _life
	projectile_velocity = _projectile_velocity * from_player.movement.facing
	hit_velocity = _hit_velocity
	projectile.scale.x = from_player.movement.facing
	if projectile is RigidBody2D:
		projectile.linear_velocity = _projectile_velocity
	elif "velocity" in projectile:
		projectile.velocity = _projectile_velocity


func _detect_character_body_collisions() -> void:
	var character_body := projectile as CharacterBody2D
	var collision: KinematicCollision2D = character_body.get_last_slide_collision()

	if not collision:
		return

	var collider := collision.get_collider()
	if not (collider is ConfigurableTileMapLayer or collider is Character):
		return

	if collider is ConfigurableTileMapLayer:
		var normal := collision.get_normal()
		var rid := collision.get_collider_rid()
		var coords: Vector2i = collider.get_coords_for_body_rid(rid)

		_notify_tile_collision(collider, coords, normal)
	elif collider is Character:
		_notify_character_collision(collider)


func _on_body_shape_entered(
	body_rid: RID,
	body: Node,
	_body_shape_index: int,
	_local_shape_index: int
) -> void:
	# For RigidBody2D, detect collisions using body_shape_entered signal
	if not (body is ConfigurableTileMapLayer or body is Character):
		return

	if body is ConfigurableTileMapLayer:
		var tile_map_layer := body as ConfigurableTileMapLayer

		# Calculate the collision tile position
		# We need to determine which tile was actually hit based on the collision normal direction
		var body_global := projectile.global_position
		var tile_position := tile_map_layer.map_to_local(tile_map_layer.local_to_map(tile_map_layer.to_local(body_global)))
		var tile_global := tile_map_layer.to_global(tile_position)
		var direction := (body_global - tile_global).normalized()

		# Determine collision side to find the adjacent tile
		# Offset body position toward the collision direction to find the hit tile
		var offset := Vector2.ZERO
		if abs(direction.x) > abs(direction.y):
			# Horizontal collision - offset horizontally
			offset = Vector2(sign(direction.x) * 64, 0)
		else:
			# Vertical collision - offset vertically
			offset = Vector2(0, sign(direction.y) * 64)

		var contact_point := body_global + offset
		var body_local := tile_map_layer.to_local(contact_point)
		var coords: Vector2i = tile_map_layer.local_to_map(body_local)

		# Normal is based on the offset direction
		var normal := Vector2.ZERO
		if abs(direction.x) > abs(direction.y):
			normal = Vector2(sign(direction.x), 0)
		else:
			normal = Vector2(0, sign(direction.y))

		_notify_tile_collision(tile_map_layer, coords, normal)
	elif body is Character:
		_notify_character_collision(body)


func _notify_tile_collision(
	tile_map_layer: ConfigurableTileMapLayer,
	coords: Vector2i,
	normal: Vector2
) -> void:
	# Determine which event(s) to trigger based on collision normal
	var events: Array[String] = []

	if abs(normal.x) > abs(normal.y):
		if normal.x > 0:
			events.append("left")
		else:
			events.append("right")
		events.append("any_side")
	else:
		if normal.y > 0:
			events.append("bottom")
			events.append("bump")
		else:
			events.append("top")
			events.append("stand")
		events.append("any_side")

	# Delegate to the tile map layer to handle behaviors
	tile_map_layer.trigger_tile_behaviors(projectile, coords, events, normal)
	projectile_hit()


func _notify_character_collision(
	character: Character
) -> void:
	if character != from_player:
		character.velocity += hit_velocity
		character.movement.hitstun(2.5)
	projectile_hit()


func projectile_hit() -> void:
	projectile.queue_free()
