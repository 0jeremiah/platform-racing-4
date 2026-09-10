class_name Stamps

static var stamp_dictionary = {
	"cactus": {"texture": preload("res://stamps/cactus.svg")},
	"petrifiedtree": {"texture": preload("res://stamps/petrifiedtree.svg"), "pr2_scale": Vector2(0.7604731394775752, 0.7606581899775617)},
	"rock2": {"texture": preload("res://stamps/rock2.svg"), "pr2_scale": Vector2(1.0, 1.0)},
	"rock": {"texture": preload("res://stamps/rock.svg"), "pr2_scale": Vector2(0.7124183006535948, 0.7078957604045119)},
	"skyscraper": {"texture": preload("res://stamps/skyscraper.svg"), "pr2_scale": Vector2(1.819209039548023, 1.819363222871995)},
	"spire2": {"texture": preload("res://stamps/spire2.svg"), "pr2_scale": Vector2(1.864342313787639, 1.867734075878872)},
	"spire": {"texture": preload("res://stamps/spire.svg"), "pr2_scale": Vector2(2.326530612244898, 2.326664241542379)},
	"tree2": {"texture": preload("res://stamps/tree2.svg"), "pr2_scale": Vector2(1.694945848375451, 1.694926796050392)},
	"tree3": {"texture": preload("res://stamps/tree3.svg"), "pr2_scale": Vector2(1.577235772357724, 1.577333333333333)},
	"tree": {"texture": preload("res://stamps/tree.svg"), "pr2_scale": Vector2(1.330998248686515, 1.330893682588598)}
	}
static var pr2_only_stamps: Dictionary = {
	"pr2-cactus": {"texture": preload("res://stamps/pr2-cactus.png")},
	"pr2-start1": {"texture": preload("res://stamps/pr2-start1.png")},
	"pr2-start2": {"texture": preload("res://stamps/pr2-start2.png")},
	"pr2-start3": {"texture": preload("res://stamps/pr2-start3.png")},
	"pr2-start4": {"texture": preload("res://stamps/pr2-start4.png")}
	}


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
