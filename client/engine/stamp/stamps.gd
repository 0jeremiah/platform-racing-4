class_name Stamps

static var stamp_dictionary = {
	"cactus": {"texture" = preload("res://engine/stamp/cactus-graphic.svg")},
	"petrifiedtree": {"texture" = preload("res://engine/stamp/petrifiedtree-graphic.svg")},
	"rock2": {"texture" = preload("res://engine/stamp/rock2-graphic.svg")},
	"rock": {"texture" = preload("res://engine/stamp/rock-graphic.svg")},
	"skyscraper": {"texture" = preload("res://engine/stamp/skyscraper-graphic.svg")},
	"spire2": {"texture" = preload("res://engine/stamp/spire2-graphic.svg")},
	"spire": {"texture" = preload("res://engine/stamp/spire-graphic.svg")},
	"tree2": {"texture" = preload("res://engine/stamp/tree2-graphic.svg")},
	"tree3": {"texture" = preload("res://engine/stamp/tree3-graphic.svg")},
	"tree": {"texture" = preload("res://engine/stamp/tree-graphic.svg")}
}
static var pr2_only_stamps: Dictionary = {
	"classic_start1": {"texture": preload("res://engine/level/PR2_Start1.png")},
	"classic_start2": {"texture": preload("res://engine/level/PR2_Start2.png")},
	"classic_start3": {"texture": preload("res://engine/level/PR2_Start3.png")},
	"classic_start4": {"texture": preload("res://engine/level/PR2_Start4.png")}
	}
# ^ this is for level editor ^


static func add_block_stamps():
	var block_stamps: Dictionary = {
		"classic_basic1": {"texture": BlockManager.get_block_texture("1")},
		"classic_basic2": {"texture": BlockManager.get_block_texture("2")},
		"classic_basic3": {"texture": BlockManager.get_block_texture("3")},
		"classic_basic4": {"texture": BlockManager.get_block_texture("4")},
		"classic_brick": {"texture": BlockManager.get_block_texture("5")},
		"classic_arrowdown": {"texture": BlockManager.get_block_texture("6")},
		"classic_arrowup": {"texture": BlockManager.get_block_texture("7")},
		"classic_arrowleft": {"texture": BlockManager.get_block_texture("8")},
		"classic_arrowright": {"texture": BlockManager.get_block_texture("9")},
		"classic_mine": {"texture": BlockManager.get_block_texture("10")},
		"classic_item": {"texture": BlockManager.get_block_texture("11")},
		"classic_start": {"texture": BlockManager.get_block_texture("12")},
		"classic_bounce": {"texture": BlockManager.get_block_texture("13")},
		"classic_change": {"texture": BlockManager.get_block_texture("14")},
		"classic_hurt": {"texture": BlockManager.get_block_texture("15")},
		"classic_ice": {"texture": BlockManager.get_block_texture("16")},
		"classic_finish": {"texture": BlockManager.get_block_texture("17")},
		"classic_crumble": {"texture": BlockManager.get_block_texture("18")},
		"classic_vanish": {"texture": BlockManager.get_block_texture("19")},
		"classic_move": {"texture": BlockManager.get_block_texture("20")},
		"classic_water": {"texture": BlockManager.get_block_texture("21")},
		"classic_rotateright": {"texture": BlockManager.get_block_texture("22")},
		"classic_rotateleft": {"texture": BlockManager.get_block_texture("23")},
		"classic_push": {"texture": BlockManager.get_block_texture("24")},
		"classic_safety": {"texture": BlockManager.get_block_texture("25")},
		"classic_iteminfinite": {"texture": BlockManager.get_block_texture("26")},
		"classic_happy": {"texture": BlockManager.get_block_texture("27")},
		"classic_sad": {"texture": BlockManager.get_block_texture("28")},
		"classic_heart": {"texture": BlockManager.get_block_texture("29")},
		"classic_time": {"texture": BlockManager.get_block_texture("30")},
		"classic_minionegg": {"texture": BlockManager.get_block_texture("31")},
		"classic_customstats": {"texture": BlockManager.get_block_texture("32")},
		"classic_teleport": {"texture": BlockManager.get_block_texture("33")},
		"classic_gear": {"texture": BlockManager.get_block_texture("34")},
		"classic_presence": {"texture": BlockManager.get_block_texture("35")},
		"classic_sun": {"texture": BlockManager.get_block_texture("36")},
		"classic_moon": {"texture": BlockManager.get_block_texture("37")},
		"classic_firefly": {"texture": BlockManager.get_block_texture("38")},
		"classic_appear": {"texture": BlockManager.get_block_texture("39")},
		"classic_enlarge": {"texture": BlockManager.get_block_texture("40")},
		"classic_shrink": {"texture": BlockManager.get_block_texture("41")},
		"classic_sticky": {"texture": BlockManager.get_block_texture("42")},
		"classic_sniper": {"texture": BlockManager.get_block_texture("43")},
		"portable_block": {"texture": BlockManager.get_block_texture("portable_block")},
		"portable_mine": {"texture": BlockManager.get_block_texture("portable_mine")}
	}
	stamp_dictionary.merge(block_stamps)


static func get_stamp(stamp_id: String) -> Texture2D:
	var texture = null
	if stamp_id in stamp_dictionary:
		texture = stamp_dictionary[stamp_id].texture
	elif stamp_id in pr2_only_stamps:
		texture = pr2_only_stamps[stamp_id].texture
	#match stamp_id:
		# sets stamps accordingly
		#"cactus": texture = cactus
		#"petrifiedtree": texture = petrifiedtree
		#"rock2": texture = rock2
		#"rock": texture = rock
		#"skyscraper": texture = skyscraper
		#"spire2": texture = spire2
		#"spire": texture = spire
		#"tree2": texture = tree2
		#"tree3": texture = tree3
		#"tree": texture = tree
	return texture
