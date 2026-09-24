extends BlockSideSetting

signal crumble_side_settings_changed

@onready var armor_box = $ArmorBox
@onready var damage_ratio_box = $DamageRatioBox

var armor: float = 10.0
var damage_ratio: float = 0.03


func _ready() -> void:
	armor_box.init("float", "10.0", 0.0, 99999999.9)
	armor_box.return_line.connect(_change_armor)
	damage_ratio_box.init("float", "0.03", 0.0, 99999999.9)
	damage_ratio_box.return_line.connect(_change_damage_ratio)
	connect_node(self, "crumble_side_settings_changed")


func _change_armor(new_armor: float):
	armor = new_armor
	emit_signal("crumble_side_settings_changed", {"armor": armor, "damage_ratio": damage_ratio})


func _change_damage_ratio(new_damage_ratio: float):
	damage_ratio = new_damage_ratio
	emit_signal("crumble_side_settings_changed", {"armor": armor, "damage_ratio": damage_ratio})


func set_side_settings(new_side_settings: Dictionary):
	if new_side_settings.has("armor"):
		armor = clamp(new_side_settings.armor, 0.0, 99999999.9)
		armor_box._update_text(str(armor))
	if new_side_settings.has("damage_ratio"):
		damage_ratio = clamp(new_side_settings.damage_ratio, 0.0, 99999999.9)
		damage_ratio_box._update_text(str(damage_ratio))
	side_settings = {"armor": armor, "damage_ratio": damage_ratio}
