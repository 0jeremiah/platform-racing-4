extends Item
class_name JetpackItem

@onready var exhaust_1 = $Exhaust1
@onready var jet_pack_fire_1 = $JetpackFire1
@onready var exhaust_2 = $Exhaust2
@onready var jet_pack_fire_2 = $JetpackFire2
var fuel_on: bool = false
var jet_pack_timer: float = 0.0
var exhaust_scale: float = 0.0
var jet_pack_fire_scale: float = 1.0
var last_delta: float = 0.0
var current_character: Character = null


func _init_item(_character: Character):
	_character.item_manager.uses = GameConfig.get_value("items-uses", "uses_jetpack")
	jet_pack_timer = GameConfig.get_value("items-effects", "jetpack_duration")
	current_character = _character


func _physics_process(_delta: float) -> void:
	if current_character != null and fuel_on:
		if current_character.movement.current_velocity.y < -700.0:
			current_character.movement.current_velocity.y -= 40.0
		elif current_character.movement.current_velocity.y <= 0.0:
			current_character.movement.current_velocity.y -= 65.0
		else:
			current_character.movement.current_velocity.y -= 75.0


func _process(delta: float):
	last_delta = delta


func process_item(_character: Character):
	exhaust_1.visible = false
	jet_pack_fire_1.visible = false
	exhaust_2.visible = false
	jet_pack_fire_2.visible = false
	if !_character.movement.hurt and Input.is_action_pressed("item"):
		using = true
		fuel_on = true
	else:
		using = false
		fuel_on = false
	if jet_pack_timer > 0:
		if fuel_on:
			jet_pack_timer -= last_delta
			exhaust_scale = randf_range(0.5, 1.0)
			exhaust_1.modulate = Color(1.0, 1.0, 1.0, exhaust_scale)
			exhaust_2.modulate = Color(1.0, 1.0, 1.0, exhaust_scale)
			jet_pack_fire_scale = randf_range(0.1, 0.5)
			jet_pack_fire_1.scale.y = jet_pack_fire_scale
			jet_pack_fire_2.scale.y = jet_pack_fire_scale
			exhaust_1.visible = true
			jet_pack_fire_1.visible = true
			exhaust_2.visible = true
			jet_pack_fire_2.visible = true
		else:
			_character.item_manager.force = Vector2(0, 0)
	else:
		_character.item_manager.uses = 0
		current_character = null
		fuel_on = false
