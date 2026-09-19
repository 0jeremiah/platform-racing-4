extends Node2D
class_name Item
## Manages player items, their activation and effects
##
## Handles acquisition, use, and disposal of all player items,
## including their forces and visual effects.

@onready var angel_wings = $AngelWingsItem
@onready var black_hole = $BlackHoleItem
@onready var ice_wave = $IceWaveItem
@onready var jet_pack = $JetpackItem
@onready var laser_gun = $LaserGunItem
@onready var lightning = $LightningItem
@onready var portable_block = $PortableBlockItem
@onready var portable_mine = $PortableMineItem
@onready var rocket_launcher = $RocketLauncherItem
@onready var shield = $ShieldItem
@onready var speed_burst = $SpeedBurstItem
@onready var super_jump = $SuperJumpItem
@onready var sword = $SwordItem
@onready var teleport = $TeleportItem

var character: Character
var item: Node2D = null
var item_id: int = 0
var item_pool: Array = []
var uses: int = 0
var reload_timer: float = 0.0
var using: bool = false
var has_force: bool = false
var force := Vector2.ZERO


func _ready() -> void:
	item_pool = [null, angel_wings, black_hole, ice_wave, jet_pack, laser_gun, lightning, portable_block,
	portable_mine, rocket_launcher, shield, speed_burst, super_jump, sword, teleport]


func init(p_character: Character):
	character = p_character


func _physics_process(delta: float) -> void:
	if using and reload_timer > 0:
		if (reload_timer - delta) > 0:
			reload_timer -= delta
		elif using:
			using = false
	
	if item and item.has_method("process_item"):
		item.process_item(character)


func _process(_delta: float) -> void:
	if item and uses <= 0:
		remove_item()
	if character:
		if item != portable_block and item != portable_mine and item != teleport:
			position = Vector2(character.item_holder_display.position.x * character.movement.facing, character.item_holder_display.position.y)
			rotation = character.item_holder_display.rotation * character.movement.facing
			scale = (character.item_holder_display.scale / character.movement.size) * character.display.scale
			modulate = character.display.modulate
			z_index = character.item_holder_display.z_index


# tada, the item system, not all items are fully implemented at the moment.
# it's also slightly unoptimized, i think.
func set_item_id(new_item_id: int) -> void:
	if character:
		if item:
			remove_item()
		if new_item_id > 0 and new_item_id < item_pool.size():
			item_id = new_item_id
			item = item_pool[item_id]
			item._init_item(character)
			item.visible = true


func try_to_use() -> void:
	if item and uses > 0 and not using:
		_use_item()


func _use_item() -> void:
	if item.has_method("activate_item"):
		item.activate_item(character)


func remove_item() -> void:
	if item:
		if item.has_method("_remove_item"):
			item._remove_item(character)
		item.visible = false
		reload_timer = 0
		uses = 0
		using = false
		item = null
		item_id = 0
		force = Vector2.ZERO
