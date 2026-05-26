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

static func get_stamp(stamp_id: String) -> Texture2D:
	var texture = null
	match stamp_id:
		# sets stamps accordingly
		"cactus": texture = cactus
		"petrifiedtree": texture = petrifiedtree
		"rock2": texture = rock2
		"rock": texture = rock
		"skyscraper": texture = skyscraper
		"spire2": texture = spire2
		"spire": texture = spire
		"tree2": texture = tree2
		"tree3": texture = tree3
		"tree": texture = tree
	return texture
