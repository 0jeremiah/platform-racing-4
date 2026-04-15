extends Control

@onready var appear_options = $AppearOptions
@onready var arrow_down_options = $ArrowDownOptions
@onready var arrow_left_options = $ArrowLeftOptions
@onready var arrow_right_options = $ArrowRightOptions
@onready var arrow_up_options = $ArrowUpOptions
@onready var bounce_options = $BounceOptions
@onready var crumble_options = $CrumbleOptions
@onready var custom_stats_options = $CustomStatsOptions
@onready var enlarge_options = $EnlargeOptions
@onready var mine_options = $MineOptions
@onready var gear_options = $GearOptions
@onready var happy_options = $HappyOptions
@onready var heart_options = $HeartOptions
@onready var hurt_options = $HurtOptions
@onready var ice_options = $IceOptions
@onready var item_options = $ItemOptions
@onready var rotate_left_options = $RotateLeftOptions
@onready var rotate_right_options = $RotateRightOptions
@onready var sad_options = $SadOptions
@onready var shrink_options = $ShrinkOptions
@onready var sticky_options = $StickyOptions
@onready var teleport_options = $TeleportOptions
@onready var time_options = $TimeOptions
@onready var vanish_options = $VanishOptions

@onready var sides_properties: Dictionary = {
	"appear": {"label": "Appear Options", "options": {"animation_duration": 0.3, "cooldown": 2.0}, "node": appear_options},
	"arrow_down": {"label": "Down Arrow Options", "options": {"force": 110.0, "direction": Vector2(0.0, 1.0)}, "node": arrow_down_options},
	"arrow_left": {"label": "Left Arrow Options", "options": {"force": 125.0, "direction": Vector2(-1.0, 0.0)}, "node": arrow_left_options},
	"arrow_right": {"label": "Right Arrow Options", "options": {"force": 125.0, "direction": Vector2(1.0, 0.0)}, "node": arrow_right_options},
	"arrow_up": {"label": "Up Arrow Options", "options": {"force": 110.0, "direction": Vector2(0.0, -1.0)}, "node": arrow_up_options},
	"bounce": {"label": "Bounce Options", "options": {"bounciness": 0.1, "speed_limit": 12500.0}, "node": bounce_options},
	"crumble": {"label": "Crumble Options", "options": {"health": 100, "armor": 10, "damage_ratio": 0.03}, "node": crumble_options},
	"custom_stats": {"label": "Custom Stats Options", "options": {"reset": false, "speed": 50, "accel": 50, "jump": 50, "skill": 50}, "node": custom_stats_options},
	"enlarge": {"label": "Enlarge Options", "options": {"exact": false, "multiplier": 2.0}, "node": enlarge_options},
	"mine": {"label": "Mine Options", "options": {"push_strength": 1000.0, "hitstun_duration": 2.5}, "node": mine_options},
	"gear": {"label": "Gear Options", "options": {"rotation": 90.0, "tick": 4000.0, "tock": 500.0}, "node": gear_options},
	"happy": {"label": "Happy Options", "options": {"amount": 5}, "node": happy_options},
	"heart": {"label": "Heart Options", "options": {"hp": 1.0, "exact": false, "invincibility": false}, "node": heart_options},
	"hurt": {"label": "Hurt Options", "options": {"push_strength": 1000.0, "hitstun_duration": 2.5}, "node": hurt_options},
	"ice": {"label": "Ice Options", "options": {"ice_friction": 0.2}, "node": ice_options},
	"item": {"label": "Item Options", "options": {"item_supply": 1, "infinite": false, "item_list": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]}, "node": item_options},
	"rotate_left": {"label": "Rotate Left Options", "options": {"rotations": -1, "rotation_speed": 0.025}, "node": rotate_left_options},
	"rotate_right": {"label": "Rotate Right Options", "options": {"rotations": 1, "rotation_speed": 0.025}, "node": rotate_right_options},
	"sad": {"label": "Sad Options", "options": {"amount": 5}, "node": sad_options},
	"shrink": {"label": "Shrink Options", "options": {"exact": false, "multiplier": 0.5}, "node": shrink_options},
	"sticky": {"label": "Sticky Options", "options": {"stickiness": 2.5}, "node": sticky_options},
	"teleport": {"label": "Teleport Options", "options": {"color": "FF7F50", "throttle_ms": 1000.0}, "node": teleport_options},
	"time": {"label": "Time Options", "options": {"seconds": 10.0}, "node": time_options},
	"vanish": {"label": "Vanish Options", "options": {"animation_duration": 0.3, "cooldown": 2.0}, "node": vanish_options}
}
