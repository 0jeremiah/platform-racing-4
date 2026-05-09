class_name Items
## Manager for game items and their initialization
##
## Registry for all available game items with their initialization
## and lookup functionality. Currently unused but prepared for future item blocks.

static var items := {
	"angel_wings": {"id": 1, "name": "Angel's Wings"},
	"black_hole": {"id": 2, "name": "Black Hole"},
	"ice_wave": {"id": 3, "name": "Ice Wave"},
	"jetpack": {"id": 4, "name": "Jet Pack"},
	"laser_gun": {"id": 5, "name": "Laser Gun"},
	"lightning": {"id": 6, "name": "Lightning"},
	"portable_block": {"id": 7, "name": "Portable Block"},
	"portable_mine": {"id": 8, "name": "Portable Mine"},
	"rocket_launcher": {"id": 9, "name": "Rocket Launcher"},
	"shield": {"id": 10, "name": "Shield"},
	"speed_burst": {"id": 11, "name": "Speed Burst"},
	"super_jump": {"id": 12, "name": "Super Jump"},
	"sword": {"id": 13, "name": "Sword"},
	"teleport": {"id": 14, "name": "Teleport"}
}


static func get_default_item_ids() -> Array:
	var default_item_ids = []
	for item in items:
		default_item_ids.append(items[item].id)
	return default_item_ids


static func get_default_item_names() -> Array:
	var default_item_names = []
	for item in items:
		default_item_names.append(items[item].names)
	return default_item_names


static func get_item_name(item_id: int) -> String:
	for item in items:
		if items[item].id == item_id:
			return item.name
	return ""


static func convert_pr2_items(pr2_items: Array) -> Array:
	var converted_items: Array = []
	for item in pr2_items:
		var converted_item = 0
		match item:
			1: converted_item = items.laser_gun.id
			2: converted_item = items.portable_mine.id
			3: converted_item = items.lightning.id
			4: converted_item = items.teleport.id
			5: converted_item = items.super_jump.id
			6: converted_item = items.jetpack.id
			7: converted_item = items.speed_burst.id
			8: converted_item = items.sword.id
			9: converted_item = items.ice_wave.id
		if converted_item > 0:
			converted_items.append(converted_item)
	return converted_items


static func convert_pr3_items(pr3_items: Array) -> Array:
	var converted_items: Array = []
	for item in pr3_items:
		var converted_item = 0
		match item:
			"a": converted_item = items.angel_wings.id
			"b": converted_item = items.black_hole.id
			"j": converted_item = items.jetpack.id
			"l": converted_item = items.laser_gun.id
			"li": converted_item = items.lightning.id
			"p": converted_item = items.portable_block.id
			"po": converted_item = items.portable_mine.id
			"r": converted_item = items.rocket_launcher.id
			"s": converted_item = items.shield.id
			"sp": converted_item = items.speed_burst.id
			"su": converted_item = items.super_jump.id
			"sw": converted_item = items.sword.id
			"t": converted_item = items.teleport.id
		if converted_item > 0:
			converted_items.append(converted_item)
	return converted_items
