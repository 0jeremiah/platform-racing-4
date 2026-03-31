extends SideOption

signal crumble_options_changed

@onready var health_box = $HealthBox
@onready var armor_box = $ArmorBox
@onready var damage_ratio_box = $DamageRatioBox

var health: float = 100.0
var armor: float = 10.0
var damage_ratio: float = 0.03


func _ready() -> void:
	health_box.init("float", "100.0", 0.00000001, 99999999.9)
	health_box.return_line.connect(_change_health)
	armor_box.init("float", "10.0", 0.0, 99999999.9)
	armor_box.return_line.connect(_change_armor)
	damage_ratio_box.init("float", "0.03", 0.0, 99999999.9)
	damage_ratio_box.return_line.connect(_change_damage_ratio)
	connect_node(self, "crumble_options_changed")


func _change_health(new_health: float):
	health = new_health
	emit_signal("crumble_options_changed", {"health": health, "armor": armor, "damage_ratio": damage_ratio})


func _change_armor(new_armor: float):
	armor = new_armor
	emit_signal("crumble_options_changed", {"health": health, "armor": armor, "damage_ratio": damage_ratio})


func _change_damage_ratio(new_damage_ratio: float):
	damage_ratio = new_damage_ratio
	emit_signal("crumble_options_changed", {"health": health, "armor": armor, "damage_ratio": damage_ratio})


func set_options(new_options: Dictionary):
	if new_options.has("health"):
		health = clamp(new_options.health, 0.00000001, 99999999.9)
		health_box._update_text(str(health))
	if new_options.has("armor"):
		armor = clamp(new_options.armor, 0.0, 99999999.9)
		armor_box._update_text(str(armor))
	if new_options.has("damage_ratio"):
		damage_ratio = clamp(new_options.damage_ratio, 0.0, 99999999.9)
		damage_ratio_box._update_text(str(damage_ratio))
	options = {"health": health, "armor": armor, "damage_ratio": damage_ratio}
