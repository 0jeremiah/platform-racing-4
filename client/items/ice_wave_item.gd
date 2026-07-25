extends Item
class_name IceWaveItem

var ice_wave = load("res://item_effects/ice_wave.tscn")
var animation_timer = Timer.new()
var ice_wave_amount: int = 3
var ice_wave_rotation: float = 0.0
@onready var animations: AnimationPlayer = $Animations


func _ready():
	animation_timer.connect("timeout", _play_idle_animation)
	animation_timer.process_callback = 0
	animation_timer.one_shot = true


func _init_item(_character: Character):
	_character.item_manager.uses = GameConfig.get_value("items-uses", "uses_ice_wave")


func _play_idle_animation():
	animations.play("idle")


func activate_item(_character: Character):
	if !_character.item_manager.using:
		_character.item_manager.using = true
		animations.stop()
		animations.play("shoot")
		animation_timer.start(animations.get_current_animation_length())
		_character.item_manager.reload_timer = GameConfig.get_value("items-uses", "reload_ice_wave")
		shoot(_character)
		_character.item_manager.uses -= 1

# ice waves seem to overwrite each other, causing-
# one of the ice waves to suddenly change direction.
# also they don't freeze blocks at the moment. maybe
# the current ice blocks mechanic that freezes the
# player instead of just slowing down the player's
# acceleration could be reserved for the ice wave?

func shoot(_character: Character):
	var layer = Game.get_target_map_layer_node()
	var spawn = layer.projectiles
	var angle_increment = 0
	var angle = 0
	if ice_wave_amount > 1:
		angle_increment = 90.0 / (ice_wave_amount - 1)
		angle = ice_wave_rotation - (45.0 + angle_increment)
	for current_ice_wave in ice_wave_amount:
		angle += angle_increment
		var ice_wave_projectile = ice_wave.instantiate()
		ice_wave_projectile.global_position = global_position
		ice_wave_projectile.rotation_degrees = angle
		ice_wave_projectile.set_projectile(ice_wave_projectile, _character.collision_layer, _character.collision_mask, GameConfig.get_value("items-effects", "ice_wave_lifetime"), Vector2(GameConfig.get_value("items-effects", "ice_wave_speed"), 0.0).rotated(ice_wave_projectile.rotation).rotated(_character.rotation), _character.movement.facing == -1, _character)
		spawn.add_child(ice_wave_projectile)
	Jukebox.play_sound("icewave")


func _remove_item(_character: Character):
	animation_timer.stop()
	_play_idle_animation()
