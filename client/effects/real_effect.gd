extends PhysicsBody2D
class_name RealEffect
## Interacts with local player and tilemaplayers (doesn't call block behaviors).

var effect: Node2D


func _setup_rigidbody_signals() -> void:
	var rigid_body := effect as RigidBody2D
	rigid_body.contact_monitor = true
	rigid_body.max_contacts_reported = 10
	rigid_body.body_shape_entered.connect(_on_body_shape_entered)


func _physics_process(_delta: float) -> void:
	# For CharacterBody2D, detect collisions using get_last_slide_collision
	if effect is CharacterBody2D:
		_detect_character_body_collisions()


func _process(_delta: float) -> void:
	if effect is CharacterBody2D:
		effect.move_and_slide()


func _detect_character_body_collisions() -> void:
	var character_body := effect as CharacterBody2D
	var collision: KinematicCollision2D = character_body.get_last_slide_collision()
	if not collision:
		return
	var collider := collision.get_collider()
	if not collider is Character:
		return
	_notify_character_collision(collider)


func set_effect_area(effect_area: Area2D) -> void:
	effect_area.collision_layer = collision_layer
	effect_area.collision_mask = collision_mask
	effect_area.body_shape_entered.connect(_on_body_shape_entered)


func set_effect(effect_node: PhysicsBody2D, p_collision_layer: int, p_collision_mask: int):
	effect = effect_node
	if effect is RigidBody2D:
		_setup_rigidbody_signals()
	collision_layer = p_collision_layer
	collision_mask = p_collision_mask


func _on_body_shape_entered(_body_rid: RID, body: Node, _body_shape_index: int, _local_shape_index: int) -> void:
	# For RigidBody2D, detect collisions using body_shape_entered signal
	if not body is Character:
		return
	_notify_character_collision(body)


func _notify_character_collision(character: Character) -> void:
	if effect.has_method("touch_local_player"):
		effect.touch_local_player(character)
