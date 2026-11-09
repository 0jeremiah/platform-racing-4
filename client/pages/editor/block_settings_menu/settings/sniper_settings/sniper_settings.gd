extends BlockSetting

signal sniper_settings_changed

@onready var sniper_tick_box = $SniperTickBox

var sniper_tick: float = ConfigurableBlockSettings.default_block_properties.sniper_tick


func _ready() -> void:
	sniper_tick_box.init("float", str(sniper_tick), 0.0, 99999999.9)
	sniper_tick_box.return_line.connect(_change_sniper_tick)
	connect_node(self, "sniper_settings_changed")


func send_signal():
	emit_signal("sniper_settings_changed", {"sniper_tick": sniper_tick})


func _change_sniper_tick(new_sniper_tick: int):
	sniper_tick = new_sniper_tick
	send_signal()


func set_settings(new_settings: Dictionary):
	if new_settings.has("sniper_tick"):
		sniper_tick = clamp(new_settings.sniper_tick, 0.0, 99999999.9)
		sniper_tick_box._update_text(str(sniper_tick))
