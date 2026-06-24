extends Node2D
class_name PR2LevelDecoder

var pr2_objects: Dictionary = {
	0: {"type": "stamp", "name": "tree_stamp", "compat_id": "tree"},
	1: {"type": "stamp", "name": "tree2_stamp", "compat_id": "tree2"},
	2: {"type": "stamp", "name": "tree3_stamp", "compat_id": "tree3"},
	3: {"type": "stamp", "name": "petrified_tree_stamp", "compat_id": "petrifiedtree"},
	4: {"type": "stamp", "name": "cactus_stamp", "compat_id": "cactus"},
	5: {"type": "stamp", "name": "rock_stamp", "compat_id": "rock"},
	6: {"type": "stamp", "name": "rock2_stamp", "compat_id": "rock2"},
	7: {"type": "stamp", "name": "spire1_stamp", "compat_id": "spire"},
	8: {"type": "stamp", "name": "spire2_stamp", "compat_id": "spire2"},
	9: {"type": "stamp", "name": "building_stamp", "compat_id": "skyscraper"},
	100: {"type": "block", "name": "basic1_block", "compat_id": "classic_basic1"},
	101: {"type": "block", "name": "basic2_block", "compat_id": "classic_basic2"},
	102: {"type": "block", "name": "basic3_block", "compat_id": "classic_basic3"},
	103: {"type": "block", "name": "basic4_block", "compat_id": "classic_basic4"},
	104: {"type": "block", "name": "brick_block", "compat_id": "classic_brick"},
	105: {"type": "block", "name": "arrow_down_block", "compat_id": "classic_arrowdown"},
	106: {"type": "block", "name": "arrow_up_block", "compat_id": "classic_arrowup"},
	107: {"type": "block", "name": "arrow_left_block", "compat_id": "classic_arrowleft"},
	108: {"type": "block", "name": "arrow_right_block", "compat_id": "classic_arrowright"},
	109: {"type": "block", "name": "mine_block", "compat_id": "classic_mine"},
	110: {"type": "block", "name": "item_block", "compat_id": "classic_item"},
	111: {"type": "block", "name": "start1_block", "compat_id": "classic_start1"},
	112: {"type": "block", "name": "start2_block", "compat_id": "classic_start2"},
	113: {"type": "block", "name": "start3_block", "compat_id": "classic_start3"},
	114: {"type": "block", "name": "start4_block", "compat_id": "classic_start4"},
	115: {"type": "block", "name": "ice_block", "compat_id": "classic_ice"},
	116: {"type": "block", "name": "finish_block", "compat_id": "classic_finish"},
	117: {"type": "block", "name": "crumble_block", "compat_id": "classic_crumble"},
	118: {"type": "block", "name": "vanish_block", "compat_id": "classic_vanish"},
	119: {"type": "block", "name": "move_block", "compat_id": "classic_move"},
	120: {"type": "block", "name": "water_block", "compat_id": "classic_water"},
	121: {"type": "block", "name": "rotate_right_block", "compat_id": "classic_rotateright"},
	122: {"type": "block", "name": "rotate_left_block", "compat_id": "classic_rotateleft"},
	123: {"type": "block", "name": "push_block", "compat_id": "classic_push"},
	124: {"type": "block", "name": "safety_block", "compat_id": "classic_safety"},
	125: {"type": "block", "name": "item_inf_block", "compat_id": "classic_iteminfinite"},
	126: {"type": "block", "name": "happy_block", "compat_id": "classic_happy"},
	127: {"type": "block", "name": "sad_block", "compat_id": "classic_sad"},
	128: {"type": "block", "name": "heart_block", "compat_id": "classic_heart"},
	129: {"type": "block", "name": "time_block", "compat_id": "classic_time"},
	130: {"type": "block", "name": "minion_egg_block", "compat_id": "classic_minionegg"},
	131: {"type": "block", "name": "custom_stats_block", "compat_id": "classic_customstats"},
	132: {"type": "block", "name": "teleport_block", "compat_id": "classic_teleport"},
	201: {"type": "background", "name": "BG1"},
	202: {"type": "background", "name": "BG2"},
	203: {"type": "background", "name": "BG3"},
	204: {"type": "background", "name": "BG4"},
	205: {"type": "background", "name": "BG5"},
	206: {"type": "background", "name": "BG6"},
	207: {"type": "background", "name": "BG7"},
	300: {"type": "text", "name": "text_code"}
}


func _ready() -> void:
	BlockManager.load_default_block_configs()


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
		# 3 - bg 1 (object background (stamps)) - 1.0 depth
		# 4 - bg 2 (object background (stamps)) - 0.5 depth
		# 5 - bg 3 (object background (stamps)) - 0.25 depth
		# 6 - draw 1 (lines) - 1.0 depth
		# 7 - draw 2 (lines) - 0.5 depth
		# 8 - draw 3 (lines) - 0.25 depth
		# 9 - bg (background)
		# 10 - bg 4 (object background (stamps)) - 1.0 depth
		# 11 - bg 5 (object background (stamps)) - 2.0 depth
		# 12 - draw 4 (lines) - 1.0 depth
		# 13 - draw 5 (lines) - 2.0 depth
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
			var converted_blocks = convert_pr2_blocks_to_pr4(data_array[1])
			return data_array[5]
			#return "`".join(data_array)
	return ""
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


func convert_pr2_blocks_to_pr4(pr2_block_string: String) -> String:
	var converted_blocks = {}
	var pr2_block_string_array = Array(pr2_block_string.split(","))
	var configurable_tile_map_layer = ConfigurableTileMapLayer.new()
	var level_encoder = LevelEncoder.new()
	for block_string in pr2_block_string_array:
		if block_string.begins_with("o"):
			var block_code_array = Array(block_string.trim_prefix("o").split(";"))
			if block_code_array[0].is_valid_int():
				var block_id = null
				if (int(block_code_array[0]) + 99) in pr2_objects and pr2_objects[(int(block_code_array[0]) + 99)].type == "block":
					block_id = int(block_code_array[0]) + 99
				elif int(block_code_array[0]) in pr2_objects and pr2_objects[int(block_code_array[0])].type == "block":
					block_id = int(block_code_array[0])
				if block_id != null:
					var start_positions_blocks = [111, 112, 113, 114]
					converted_blocks[Vector2i(int(block_code_array[1]), int(block_code_array[2]))] = {
						"id" = "12" if int(block_code_array[0]) in start_positions_blocks else block_id - 99,
						"coords" = Vector2i(int(block_code_array[1]), int(block_code_array[2]))
					}
					if block_code_array.get(3) != null:
						var options = {}
						if block_code_array[0] == "110" or block_code_array[0] == "125":
							var items = []
							if block_code_array.get(3) != null:
								items = Array(block_code_array[3].split("-"))
								var converted_items = []
								for item in items:
									converted_items.append(int(item))
								converted_items.sort()
								converted_items = Items.convert_pr2_items(converted_items)
								options = {
									"item_array": converted_items
									}
							else:
								var converted_items = Items.convert_pr2_items([1, 2, 3, 4, 5, 6, 7, 8, 9])
								#options = {
									#"infinite_items": true if block_code_array[0] == "125" else false,
									#"item_supply": 9999999 if block_code_array[0] == 1 else false
									#}
								options = {
									"item_array": converted_items
									}
						if block_code_array[0] == "126" or block_code_array[0] == "127":
							var amount = 5 if block_code_array.get(3) == null else int(block_code_array[3])
							options = {
									"amount": amount
									}
						if block_code_array[0] == "131":
							var reset = true if block_code_array.get(3) == "reset" else false
							var stats = [] if reset else Array(block_code_array[3].split("-"))
							var speed = 50 if stats.get(0) == null else int(stats[0])
							var accel = 50 if stats.get(1) == null else int(stats[1])
							var jump = 50 if stats.get(2) == null else int(stats[2])
							if block_code_array[3] != "reset":
								options = {
									"reset": reset,
									"speed": speed,
									"accel": accel,
									"jump": jump
									}
						elif block_code_array[0] == "132":
							var color = get_color(int(block_code_array[0])).to_html(false)
							if block_code_array[3] != "reset":
								options = {
									"teleport_color": color
									}
						#converted_blocks[Vector2i(int(block_code_array[1]), int(block_code_array[2]))]["options"] = options
					configurable_tile_map_layer.set_cell_by_id(Vector2i(int(block_code_array[1]), int(block_code_array[2])), str(block_id - 99))
	return level_encoder.new_encode_chunks(configurable_tile_map_layer)


func convert_pr2_lines_to_pr4(pr2_lines_string: String) -> String:
	var brush_size: int = 4
	var brush_color: Color = Color("000000")
	var mode = "draw"
	var pr2_lines_string_array = Array(pr2_lines_string.split(","))
	var level_encoder = LevelEncoder.new()
	var lines_holder = Node2D.new()
	for line_string in pr2_lines_string_array:
		var line_code = line_string.substr(0, 1)
		var line_params = line_string.substr(1)
		var draw_lines = []
		if line_code.begins_with("d"):
			var stroke_array = Array(line_params.split(";"))
			var brush_position = Vector2(int(line_params[0]), int(line_params[1]))
			draw_lines.append(Vector2(brush_position.x, brush_position.y))
			var stroke_increment: int = 2
			while stroke_increment < stroke_array.size():
				brush_position += Vector2(int(stroke_array[stroke_increment]), int(stroke_array[stroke_increment + 1]))
				draw_lines.append(Vector2(brush_position.x, brush_position.y))
				stroke_increment += 2
		elif line_code.begins_with("c"):
			brush_color = get_color(line_params)
		elif line_code.begins_with("t"):
			brush_size = line_params * 2
		elif line_code.begins_with("m"):
			mode = line_params
		elif line_code.begins_with("o"):
			pass
		elif line_code.begins_with("u"):
			pass
		if mode == "erase":
			if !draw_lines.is_empty():
				#var line2d = Line2D.new()
				#line2d.position = Vector2(0.0, 0.0)
				#line2d.points = []
				#line2d.width = 4.0 * 2
				#line2d.color = Color("000000")
				#var draw_material = CanvasItemMaterial.new()
				#draw_material.blend_mode = CanvasItemMaterial.BLEND_MODE_SUB
				#lines_holder = add_child(line2d)
				draw_lines = []
		if mode == "draw":
			if !draw_lines.is_empty():
				#var line2d = Line2D.new()
				#line2d.position = Vector2(0.0, 0.0)
				#line2d.points = []
				#line2d.width = 4.0 * 2
				#line2d.color = Color("000000")
				#var draw_material = CanvasItemMaterial.new()
				#draw_material.blend_mode = CanvasItemMaterial.BLEND_MODE_MIX
				#lines_holder = add_child(line2d)
				draw_lines = []
	return ""


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


func get_color(color_int: int) -> Color:
	if color_int >= 0:
		var r = color_int >> 16 & 0xFF
		var g = color_int >> 16 & 0xFF
		var b = color_int >> 16 & 0xFF
		return Color.from_rgba8(r, g, b)
	else:
		return Color(1, 1, 1)


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
