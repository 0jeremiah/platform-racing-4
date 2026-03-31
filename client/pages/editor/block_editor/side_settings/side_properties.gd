extends Control

var sides_properties: Dictionary = {
	"appear": {"label": "Appear Options", "options": {"animation_duration": 0.3, "cooldown": 2.0}, "node": null},
	"arrow_down": {"label": "Down Arrow Options", "options": {"force": 110.0, "direction": Vector2(0.0, 1.0)}, "node": null},
	"arrow_left": {"label": "Left Arrow Options", "options": {"force": 125.0, "direction": Vector2(-1.0, 0.0)}, "node": null},
	"arrow_right": {"label": "Right Arrow Options", "options": {"force": 125.0, "direction": Vector2(1.0, 0.0)}, "node": null},
	"arrow_up": {"label": "Up Arrow Options", "options": {"force": 110.0, "direction": Vector2(0.0, -1.0)}, "node": null},
	"bounce": {"label": "Bounce Options", "options": {"bounciness": 0.1, "speed_limit": 12500.0}, "node": null},
	"crumble": {"label": "Crumble Options", "options": {"health": 100, "armor": 10, "damage_ratio": 0.03}, "node": null},
	"custom_stats": {"label": "Custom Stats Options", "options": {"reset": false, "speed": 50, "accel": 50, "jump": 50, "skill": 50}, "node": null},
	"enlarge": {"label": "Enlarge Options", "options": {"exact": false, "multiplier": 2.0}, "node": null},
	"mine": {"label": "Mine Options", "options": {"push_strength": 1000.0, "hitstun_duration": 2.5}, "node": null},
	"gear": {"label": "Gear Options", "options": {"rotation": 90.0, "tick": 4000.0, "tock": 500.0}, "node": null},
	"happy": {"label": "Happy Options", "options": {"amount": 5}, "node": null},
	"heart": {"label": "Heart Options", "options": {"hp": 1.0, "exact": false, "invincibility": false}, "node": null},
	"hurt": {"label": "Hurt Options", "options": {"push_strength": 1000.0, "hitstun_duration": 2.5}, "node": null},
	"ice": {"label": "Ice Options", "options": {"ice_friction": 0.2}, "node": null},
	"item": {"label": "Item Options", "options": {"item_supply": 1, "infinite": false, "item_list": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]}, "node": null},
	"rotate_left": {"label": "Rotate Left Options", "options": {"rotations": -1, "rotation_speed": 0.025}, "node": null},
	"rotate_right": {"label": "Rotate Right Options", "options": {"rotations": 1, "rotation_speed": 0.025}, "node": null},
	"sad": {"label": "Sad Options", "options": {"amount": 5}, "node": null},
	"shrink": {"label": "Shrink Options", "options": {"exact": false, "multiplier": 0.5}, "node": null},
	"sticky": {"label": "Sticky Options", "options": {"stickiness": 2.5}, "node": null},
	"teleport": {"label": "Teleport Options", "options": {"color": "FF7F50", "throttle_ms": 1000.0}, "node": null},
	"time": {"label": "Time Options", "options": {"seconds": 10.0}, "node": null},
	"vanish": {"label": "Vanish Options", "options": {"animation_duration": 0.3, "cooldown": 2.0}, "node": null}
}
