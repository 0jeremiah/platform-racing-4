class_name Stamps

const cactus = preload("res://engine/stamp/cactus-graphic.svg")
const petrifiedtree = preload("res://engine/stamp/petrifiedtree-graphic.svg")
const rock2 = preload("res://engine/stamp/rock2-graphic.svg")
const rock = preload("res://engine/stamp/rock-graphic.svg")
const skyscraper = preload("res://engine/stamp/skyscraper-graphic.svg")
const spire2 = preload("res://engine/stamp/spire2-graphic.svg")
const spire = preload("res://engine/stamp/spire-graphic.svg")
const tree2 = preload("res://engine/stamp/tree2-graphic.svg")
const tree3 = preload("res://engine/stamp/tree3-graphic.svg")
const tree = preload("res://engine/stamp/tree-graphic.svg")
static var stamp_list: Array = ["cactus", "petrifiedtree", "rock2", "rock", "skyscraper",
"spire2", "spire", "tree2", "tree3", "tree"]
static var stamp_graphic_list: Array = [cactus, petrifiedtree, rock2, rock, skyscraper,
spire2, spire, tree2, tree3, tree]
# ^ this is for level editor ^

static func get_stamp(sprite: Sprite2D, p_id: String) -> void:
	var stamp_id = p_id
	if stamp_id in stamp_list:
		match stamp_id:
			# sets stamps accordingly
			"cactus": sprite.texture = cactus
			"petrifiedtree": sprite.texture = petrifiedtree
			"rock2": sprite.texture = rock2
			"rock": sprite.texture = rock
			"skyscraper": sprite.texture = skyscraper
			"spire2": sprite.texture = spire2
			"spire": sprite.texture = spire
			"tree2": sprite.texture = tree2
			"tree3": sprite.texture = tree3
			"tree": sprite.texture = tree
	else:
		sprite.texture = cactus

static func get_stamp_texture_rect(sprite: TextureRect, p_id: String) -> void:
	var stamp_id = p_id
	if stamp_id in stamp_list:
		match stamp_id:
			# sets stamps accordingly
			"cactus": sprite.texture = cactus
			"petrifiedtree": sprite.texture = petrifiedtree
			"rock2": sprite.texture = rock2
			"rock": sprite.texture = rock
			"skyscraper": sprite.texture = skyscraper
			"spire2": sprite.texture = spire2
			"spire": sprite.texture = spire
			"tree2": sprite.texture = tree2
			"tree3": sprite.texture = tree3
			"tree": sprite.texture = tree
	else:
		sprite.texture = cactus
