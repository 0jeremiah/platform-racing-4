extends Control

@onready var general_settings = $GeneralSettings
@onready var stat_settings = $StatSettings
@onready var item_settings = $ItemSettings
@onready var teleport_settings = $TeleportSettings
@onready var gear_settings = $GearSettings

@onready var properties: Dictionary = {
	"general": {"label": "General Settings", "settings": {"health": 100.0, "coin_value": 3}, "node": general_settings},
	"stat": {"label": "Stat Settings", "settings": {"infinite_stats": false, "stat_supply": 1}, "node": stat_settings},
	ConfigurableBlockSideSettings.ITEM: {"label": "Item Settings", "settings": {"infinite_items": false, "item_supply": 1}, "node": item_settings},
	ConfigurableBlockSideSettings.TELEPORT: {"label": "Teleport Settings", "settings": {"teleport_color": "FF7F50", "teleport_throttle_ms": 1000.0}, "node": teleport_settings},
	ConfigurableBlockSettings.GEAR: {"label": "Gear Settings", "settings": {"gear_rotation": 90.0, "gear_tick": 4000.0, "gear_tock": 500.0}, "node": gear_settings}
}
