extends PhysicsBody2D
class_name ProjectileEffect
## Same thing as TileCollisionDetector except designed specifically for projectiles.

var projectile: Node2D
var life: float = 3.3
var from = null


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
	if projectile is CharacterBody2D:
		projectile.move_and_slide()


func _detect_character_body_collisions() -> void:
	var character_body := projectile as CharacterBody2D
	var collision: KinematicCollision2D = character_body.get_last_slide_collision()
	if not collision:
		return
	var collider := collision.get_collider()
	var parent = collider.get_parent()
	if not (parent is ConfigurableTileMapLayer or collider is Character):
		return
	if parent is ConfigurableTileMapLayer:
		var normal := collision.get_normal()
		var rid := collision.get_collider_rid()
		var coords = null
		if parent.tile_set is TileSetAtlasSource:
			coords = parent.get_coords_for_body_rid(rid)
		elif collision.get_collider() is BlockScene:
			coords = collision.get_collider().get_coords()
		if coords:
			_notify_tile_collision(parent, coords, normal)
	elif collider is Character:
		_notify_character_collision(collider)


func set_projectile_area(projectile_area: Area2D) -> void:
	projectile_area.collision_layer = collision_layer
	projectile_area.collision_mask = collision_mask
	projectile_area.body_shape_entered.connect(_on_body_shape_entered)


func set_projectile(projectile_node: PhysicsBody2D, p_collision_layer: int, p_collision_mask: int, p_life: float, p_velocity: Vector2, face_left: bool = false, p_from = null):
	projectile = projectile_node
	if projectile is RigidBody2D:
		_setup_rigidbody_signals()
	collision_layer = p_collision_layer
	collision_mask = p_collision_mask
	life = p_life
	var projectile_velocity = p_velocity
	if face_left:
		projectile_velocity *= Vector2(-1, -1)
		projectile.scale.x = -1
	if projectile is RigidBody2D:
		projectile.linear_velocity = projectile_velocity
	elif projectile is CharacterBody2D:
		projectile.velocity = projectile_velocity
	if p_from:
		from = p_from


func _on_body_shape_entered(_body_rid: RID, body: Node, _body_shape_index: int, _local_shape_index: int) -> void:
	# For RigidBody2D, detect collisions using body_shape_entered signal
	var parent = body.get_parent()
	if not (parent is ConfigurableTileMapLayer or body is Character):
		return

	if parent is ConfigurableTileMapLayer:
		var tile_map_layer := parent as ConfigurableTileMapLayer

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


func _notify_tile_collision(tile_map_layer: ConfigurableTileMapLayer, coords: Vector2i, normal: Vector2) -> void:
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
		else:
			events.append("top")
		events.append("any_side")
	events.append("bump")

	# Tells projectile to handle hitting blocks
	if projectile.has_method("hit_block"):
		projectile.hit_block(tile_map_layer, coords, events, normal)


func touch_block(tile_map_layer: ConfigurableTileMapLayer, coords: Vector2i, events: Array[String], normal: Vector2 = Vector2.ZERO) -> void:
	var block_id = tile_map_layer.get_block(coords).id
	if block_id == "":
		return

	var block: ConfigurableBlock = BlockManager._blocks.get(block_id)
	if not block:
		return

	for event in events:
		block.on(event, self, tile_map_layer, coords, normal)
	queue_free()


func _notify_character_collision(character: Character) -> void:
	if character != from and projectile.has_method("hit_player"):
		projectile.hit_player(character)
