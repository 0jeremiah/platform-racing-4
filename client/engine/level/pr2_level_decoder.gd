extends Node2D
class_name PR2LevelDecoder

var pr2_objects: Dictionary = {
	0: {"type": "stamp", "name": "tree_stamp"},
	1: {"type": "stamp", "name": "tree2_stamp"},
	2: {"type": "stamp", "name": "tree3_stamp"},
	3: {"type": "stamp", "name": "petrified_tree_stamp"},
	4: {"type": "stamp", "name": "cactus_stamp"},
	5: {"type": "stamp", "name": "rock_stamp"},
	6: {"type": "stamp", "name": "rock2_stamp"},
	7: {"type": "stamp", "name": "spire1_stamp"},
	8: {"type": "stamp", "name": "spire2_stamp"},
	9: {"type": "stamp", "name": "building_stamp"},
	101: {"type": "block", "name": "basic1_block"},
	102: {"type": "block", "name": "basic2_block"},
	103: {"type": "block", "name": "basic3_block"},
	104: {"type": "block", "name": "basic4_block"},
	105: {"type": "block", "name": "brick_block"},
	106: {"type": "block", "name": "arrow_down_block"},
	107: {"type": "block", "name": "arrow_up_block"},
	108: {"type": "block", "name": "arrow_left_block"},
	109: {"type": "block", "name": "arrow_right_block"},
	110: {"type": "block", "name": "mine_block"},
	111: {"type": "block", "name": "item_block"},
	112: {"type": "block", "name": "start1_block"},
	113: {"type": "block", "name": "start2_block"},
	114: {"type": "block", "name": "start3_block"},
	115: {"type": "block", "name": "start4_block"},
	116: {"type": "block", "name": "ice_block"},
	117: {"type": "block", "name": "finish_block"},
	118: {"type": "block", "name": "crumble_block"},
	119: {"type": "block", "name": "move_block"},
	120: {"type": "block", "name": "water_block"},
	121: {"type": "block", "name": "rotate_right_block"},
	122: {"type": "block", "name": "rotate_left_block"},
	123: {"type": "block", "name": "push_block"},
	124: {"type": "block", "name": "item_inf_block"},
	125: {"type": "block", "name": "safety_block"},
	126: {"type": "block", "name": "happy_block"},
	127: {"type": "block", "name": "sad_block"},
	128: {"type": "block", "name": "heart_block"},
	129: {"type": "block", "name": "time_block"},
	130: {"type": "block", "name": "minion_egg_block"},
	131: {"type": "block", "name": "custom_stats_block"},
	132: {"type": "block", "name": "teleport_block"},
	201: {"type": "background", "name": "BG1"},
	202: {"type": "background", "name": "BG2"},
	203: {"type": "background", "name": "BG3"},
	204: {"type": "background", "name": "BG4"},
	205: {"type": "background", "name": "BG5"},
	206: {"type": "background", "name": "BG6"},
	207: {"type": "background", "name": "BG7"},
	300: {"type": "text", "name": "text_code"}
}


func decode_pr2_level(pr2_level: String) -> String:
	var decoded_level = {}
	var pr2_level_data_array = pr2_level.split("&")
	var pr2_level_data = {}
	for data in pr2_level_data_array:
		var data_string = data.split("=")
		var data1 = data_string[0]
		var data2 = null
		if data_string[1]:
			data2 = data_string[1]
		pr2_level_data[data1] = data2
	if "data" in pr2_level_data:
		var data_array = Array(pr2_level_data.data.split("`"))
		# 0 - version number
		# 1 - background color
		# 2 - block bg (blocks)
		# 3 - bg 1 (object background (stamps?))
		# 4 - bg 2 (object background (stamps?))
		# 5 - bg 3 (object background (stamps?))
		# 6 - draw 1 (lines)
		# 7 - draw 2 (lines)
		# 8 - draw 3 (lines)
		# 9 - bg (background)
		# 10 - bg 4 (object background (stamps?))
		# 11 - bg 5 (object background (stamps?))
		# 12 - draw 4 (lines)
		# 13 - draw 5 (lines)
		var version = data_array[0]
		if version == "m1" or version == "m2" or version == "m3" or version == "m4":
			#d = add line
			#c = color
			#t = brush size
			#m = mode
			#o = place object (stamps/blocks)
			#u = text
			#erase = erase (erase line in pr2)
			#draw = draw (raster line in pr2)
			data_array.remove_at(0)
			data_array[0] = str(("0x" + data_array[0]).hex_to_int())
			if version == "m1":
				data_array[1] = decode_objectstring(data_array[1])
				data_array[2] = decode_objectstring(data_array[2])
				data_array[3] = decode_objectstring(data_array[3])
				data_array[4] = decode_objectstring(data_array[4])
			elif version == "m2" or version == "m3" or version == "m4":
				if version == "m2":
					data_array[1] = decode_objectstring2(data_array[1])
				elif version == "m3":
					data_array[1] = decode_objectstring2(data_array[1], 30)
				else:
					data_array[1] = decode_blockstring(data_array[1])
				data_array[2] = decode_objectstring2(data_array[2])
				data_array[3] = decode_objectstring2(data_array[3])
				data_array[4] = decode_objectstring2(data_array[4])
				if data_array.get(9) != null:
					data_array[9] = decode_objectstring2(data_array[9])
				if data_array.get(10) != null:
					data_array[10] = decode_objectstring2(data_array[10])
			return "`".join(data_array)
	return pr2_level
	#return {
		#"title": pr2_level_data.get("title", "pr2_level"),
		#"description": pr2_level_data.get("note", ""),
		#"map_layers": [],
		#"art_layers": [],
		#"properties": {
			#"background": "pr2_field",
			#"fadeColor": pr2_level_data.data[1],
			#"music": get_music(pr2_level_data.get("music", "random")),
			#"level_type": pr2_level_data.get("gameMode", "race"),
			#"time": pr2_level_data.get("max_time", 120),
			#"gravity": pr2_level_data.get("gravity", 1.0),
			#"sfchm_chance": pr2_level_data.get("cowboyChance", 0),
			#"wind_chance": 0,
			#"snow_chance": 0,
			#"alien_chance": 0,
			#"items": Items.convert_pr2_items(Array(pr2_level_data.get("items", "").split("`"))),
			#"game_config_overrides": []
			#},
		#}


func decode_objectstring(objectstring: String) -> String:
	var loc_7: int = 0
	var loc_8: int = NAN
	var loc_9: int = NAN
	var loc_10: int = NAN
	var loc_11: int = NAN
	var loc_2: Array = Array(objectstring.split(","))
	var loc_3: Array = loc_2.pop_front().split(";")
	var loc_4: int = ("0x" + loc_3[0]).hex_to_int()
	var loc_5: int = ("0x" + loc_3[1]).hex_to_int()
	var loc_6: int = 0
	while loc_6 < loc_2.size():
		loc_3 = loc_2[loc_6].split(";")
		loc_7 = ("0x" + loc_3[0]).hex_to_int()
		loc_8 = ("0x" + loc_3[1]).hex_to_int() + loc_4
		loc_9 = ("0x" + loc_3[2]).hex_to_int() + loc_5
		loc_2[loc_6] = "o" + str(loc_7) + ";" + str(loc_8) + ";" + str(loc_9)
		if loc_3.get(3) != null:
			loc_10 = ("0x" + loc_3[3]).hex_to_int() / 100
			loc_11 = ("0x" + loc_3[4]).hex_to_int() / 100
			loc_2[loc_6] = loc_2[loc_6] + ";" + str(loc_10) + ";" + str(loc_11)
		loc_6 += 1
	return ",".join(loc_2)


func decode_objectstring2(objectstring: String, param2: int = 1) -> String:
	var loc_3: int = NAN
	var loc_4: int = NAN
	var loc_6: String = ""
	var loc_7: int = 0
	var loc_10: int = 0
	var loc_11: Array = []
	var loc_12: int = 0
	var loc_13: int = 0
	var loc_14: String = ""
	var loc_15: int = 0
	var loc_5: Array = objectstring.split(",") if objectstring != "" else []
	var loc_8: int = 0
	var loc_9: int = 0
	if loc_5.size() > 0:
		loc_10 = 0
		while loc_10 < loc_5.size():
			loc_3 = 0
			loc_4 = 0
			loc_11 = loc_5[loc_10].split(";")
			loc_12 = int(loc_11[0])
			loc_13 = int(loc_11[1])
			loc_8 += loc_12
			loc_9 += loc_13
			if loc_11.get(2) == "t":
				loc_14 = loc_11[3]
				loc_15 = int(loc_11[4])
				loc_3 = int(loc_11[5])
				loc_4 = int(loc_11[6])
				loc_5[loc_10] = "u" + str(loc_14) + ";" + str(loc_8) + ";" + str(loc_9) + ";" + str(loc_15) + ";" + str(loc_3) + ";" + str(loc_4)
			else:
				if loc_11.get(4) != null:
					loc_7 = int(loc_11[2])
					loc_3 = int(loc_11[3]) / 100
					loc_4 = int(loc_11[4]) / 100
				elif loc_11.get(3) != null:
					loc_3 = int(loc_11[2]) / 100
					loc_4 = int(loc_11[3]) / 100
				elif loc_11.get(2) != null:
					loc_7 = int(loc_11[2])
				loc_5[loc_10] = "o" + str(loc_7) + ";" + str(loc_8 * param2) + ";" + str(loc_9 * param2)
				if loc_3 != 0 and loc_4 != 0:
					loc_5[loc_10] = loc_5[loc_10] + ";" + str(loc_3) + ";" + str(loc_4)
			loc_10 += 1
		loc_6 = ",".join(loc_5)
	return loc_6


func decode_blockstring(blockstring: String) -> String:
	var loc_3: String = ""
	var loc_4: int = 0
	var loc_7: int = 0
	var loc_8: Array = []
	var loc_9: int = 0
	var loc_10: int = 0
	var loc_11: String = ""
	var loc_2: Array = blockstring.split(",") if blockstring != "" else []
	var loc_5: int = 0
	var loc_6: int = 0
	if loc_2.size() > 0:
		loc_7 = 0
		while loc_7 < loc_2.size():
			loc_8 = loc_2[loc_7].split(";")
			loc_9 = int(loc_8[0])
			loc_10 = int(loc_8[1])
			loc_5 += loc_9
			loc_6 += loc_10
			if loc_8.get(2) != null:
				loc_4 = int(loc_8[2])
			loc_11 = ""
			if loc_8.get(3) != null:
				loc_11 = ";" + loc_8[3]
			loc_2[loc_7] = "o" + str(loc_4) + ";" + str(loc_5 * 30) + ";" + str(loc_6 * 30) + str(loc_11)
			loc_7 += 1
		loc_3 = ",".join(loc_2)
	return loc_3


func convert_pr2_blocks_to_pr4(pr2_block_string: String) -> Dictionary:
	return {}


func get_music(id: String = "") -> String:
	var full_music_list = Jukebox.get_music_list()
	var music_list = {}
	for song in full_music_list.keys():
		if full_music_list.get(song).group == "pr2":
			music_list.push_back(song)
	if id.is_valid_int():
		if int(id) > 0 and music_list.size() - 1 >= int(id) and music_list[int(id)] != "":
			return music_list[int(id)]
		elif int(id) == 0:
			return "none"
	return "random"


#var background_color = data_array.get(1)
#var block_layer = data_array.get(2)
#var bg_1 = data_array.get(3)
#var bg_2 = data_array.get(4)
#var bg_3 = data_array.get(5)
#var draw_1 = data_array.get(6)
#var draw_2 = data_array.get(7)
#var draw_3 = data_array.get(8)
#var bg = data_array.get(9)
#var bg_4 = data_array.get(10)
#var bg_5 = data_array.get(11)
#var draw_4 = data_array.get(12)
#var draw_5 = data_array.get(13)
