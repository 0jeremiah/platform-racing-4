extends BlockSetting

signal general_settings_changed

@onready var health_box = $HealthBox
@onready var coin_value_box = $CoinValueBox

var health: float = ConfigurableBlockSettings.default_block_properties.health
var coin_value: float = ConfigurableBlockSettings.default_block_properties.coin_value


func _ready() -> void:
	health_box.init("float", str(health), 0.00000001, 99999999.9)
	health_box.return_line.connect(_change_health)
	coin_value_box.init("float", str(coin_value), 0.0, 99999999.9)
	coin_value_box.return_line.connect(_change_coin_value)
	connect_node(self, "general_settings_changed")


func _change_health(new_health: float):
	health = new_health
	emit_signal("general_settings_changed", {"health": health, "coin_value": coin_value})


func _change_coin_value(new_coin_value: float):
	coin_value = new_coin_value
	emit_signal("general_settings_changed", {"health": health, "coin_value": coin_value})


func set_settings(new_settings: Dictionary):
	if new_settings.has("health"):
		health = clamp(new_settings.health, 0.00000001, 99999999.9)
		health_box._update_text(str(health))
	if new_settings.has("coin_value"):
		coin_value = clamp(new_settings.coin_value, 0.0, 99999999.9)
		coin_value_box._update_text(str(coin_value))
