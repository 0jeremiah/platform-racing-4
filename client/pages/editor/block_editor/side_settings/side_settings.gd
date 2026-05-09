extends Control

@onready var appear_side_settings = $AppearSideSettings
@onready var arrow_side_settings = $ArrowSideSettings
@onready var bounce_side_settings = $BounceSideSettings
@onready var size_side_settings = $SizeSideSettings
@onready var crumble_side_settings = $CrumbleSideSettings
@onready var custom_stats_side_settings = $CustomStatsSideSettings
@onready var mine_side_settings = $MineSideSettings
@onready var heart_side_settings = $HeartSideSettings
@onready var hurt_side_settings = $HurtSideSettings
@onready var ice_side_settings = $IceSideSettings
@onready var item_side_settings = $ItemSideSettings
@onready var rotate_side_settings = $RotateSideSettings
@onready var shrink_side_settings = $ShrinkSideSettings
@onready var stats_side_settings = $StatsSideSettings
@onready var sticky_side_settings = $StickySideSettings
@onready var time_side_settings = $TimeSideSettings
@onready var vanish_side_settings = $VanishSideSettings

@onready var sides_properties: Dictionary = {
	ConfigurableBlockSideSettings.APPEAR: {"label": "Appear Side Settings", "side_settings": {"animation_duration": 0.3, "cooldown": 2.0}, "node": appear_side_settings},
	ConfigurableBlockSideSettings.ARROW: {"label": "Arrow Side Settings", "side_settings": {"horizontal_force": 125.0, "vertical_force": 110.0, "direction": {"x": 0.0, "y": 1.0}}, "node": arrow_side_settings},
	ConfigurableBlockSideSettings.BOUNCE: {"label": "Bounce Side Settings", "side_settings": {"bounciness": 0.1, "speed_limit": 12500.0}, "node": bounce_side_settings},
	ConfigurableBlockSideSettings.CHANGE_SIZE: {"label": "Size Side Settings", "side_settings": {"exact": false, "multiplier": 2.0}, "node": size_side_settings},
	ConfigurableBlockSideSettings.CHANGE_STATS: {"label": "Stats Side Settings", "side_settings": {"amount": 5}, "node": stats_side_settings},
	ConfigurableBlockSideSettings.CRUMBLE: {"label": "Crumble Side Settings", "side_settings": {"health": 100, "armor": 10, "damage_ratio": 0.03}, "node": crumble_side_settings},
	ConfigurableBlockSideSettings.CUSTOM_STATS: {"label": "Custom Stats Side Settings", "side_settings": {"reset": false, "speed": 50, "accel": 50, "jump": 50, "skill": 50}, "node": custom_stats_side_settings},
	ConfigurableBlockSideSettings.MINE: {"label": "Mine Side Settings", "side_settings": {"push_strength": 1000.0, "hitstun_duration": 2.5}, "node": mine_side_settings},
	ConfigurableBlockSideSettings.HEART: {"label": "Heart Side Settings", "side_settings": {"hp": 1.0, "exact": false, "invincibility": false}, "node": heart_side_settings},
	ConfigurableBlockSideSettings.HURT: {"label": "Hurt Side Settings", "side_settings": {"push_strength": 1000.0, "hitstun_duration": 2.5}, "node": hurt_side_settings},
	ConfigurableBlockSideSettings.ICE: {"label": "Ice Side Settings", "side_settings": {"ice_friction": 0.2}, "node": ice_side_settings},
	ConfigurableBlockSideSettings.ITEM: {"label": "Item Side Settings", "side_settings": {"item_supply": 1, "infinite": false, "item_list": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]}, "node": item_side_settings},
	ConfigurableBlockSideSettings.ROTATE: {"label": "Rotate Side Settings", "side_settings": {"rotations": 1, "rotation_speed": 0.025}, "node": rotate_side_settings},
	ConfigurableBlockSideSettings.STICKY: {"label": "Sticky Side Settings", "side_settings": {"stickiness": 2.5}, "node": sticky_side_settings},
	ConfigurableBlockSideSettings.TIME: {"label": "Time Side Settings", "side_settings": {"seconds": 10.0}, "node": time_side_settings},
	ConfigurableBlockSideSettings.VANISH: {"label": "Vanish Side Settings", "side_settings": {"animation_duration": 0.3, "cooldown": 2.0}, "node": vanish_side_settings}
}
