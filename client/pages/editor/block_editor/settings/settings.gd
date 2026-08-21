extends Control

@onready var general_settings = $GeneralSettings
@onready var move_settings = $MoveSettings
@onready var change_settings = $ChangeSettings
@onready var stat_settings = $StatSettings
@onready var item_settings = $ItemSettings
@onready var teleport_settings = $TeleportSettings
@onready var gear_settings = $GearSettings
@onready var time_settings = $TimeSettings

@onready var properties: Dictionary = {
	"general": {"label": "General Settings", "settings": {"health": ConfigurableBlockSettings.default_block_properties.health, "coin_value": ConfigurableBlockSettings.default_block_properties.coin_value}, "node": general_settings},
	ConfigurableBlockSettings.MOVE: {"label": "Move Settings", "settings": {"move_tick": ConfigurableBlockSettings.default_block_properties.move_tick, "move_pattern": ConfigurableBlockSettings.default_block_properties.move_pattern, "randomize_move_pattern": ConfigurableBlockSettings.default_block_properties.randomize_move_pattern, "loop_move_pattern": ConfigurableBlockSettings.default_block_properties.loop_move_pattern}, "node": move_settings},
	ConfigurableBlockSettings.CHANGE: {"label": "Change Settings", "settings": {"change_tick": ConfigurableBlockSettings.default_block_properties.change_tick, "change_pattern": ConfigurableBlockSettings.default_block_properties.change_pattern}, "node": change_settings},
	"stat": {"label": "Stat Settings", "settings": {"infinite_stats": ConfigurableBlockSettings.default_block_properties.infinite_stats, "stat_supply": ConfigurableBlockSettings.default_block_properties.stat_supply}, "node": stat_settings},
	ConfigurableBlockSideSettings.ITEM: {"label": "Item Settings", "settings": {"infinite_items": ConfigurableBlockSettings.default_block_properties.infinite_items, "item_supply": ConfigurableBlockSettings.default_block_properties.item_supply}, "node": item_settings},
	ConfigurableBlockSideSettings.TELEPORT: {"label": "Teleport Settings", "settings": {"teleport_color": ConfigurableBlockSettings.default_block_properties.teleport_color, "teleport_throttle_ms": ConfigurableBlockSettings.default_block_properties.teleport_throttle_ms}, "node": teleport_settings},
	ConfigurableBlockSideSettings.TIME: {"label": "Time Settings", "settings": {"infinite_time": ConfigurableBlockSettings.default_block_properties.infinite_time, "time_supply": ConfigurableBlockSettings.default_block_properties.time_supply}, "node": time_settings},
	ConfigurableBlockSettings.GEAR: {"label": "Gear Settings", "settings": {"gear_rotation": ConfigurableBlockSettings.default_block_properties.gear_rotation, "gear_tick": ConfigurableBlockSettings.default_block_properties.gear_tick, "gear_tock": ConfigurableBlockSettings.default_block_properties.gear_tock}, "node": gear_settings}
}
