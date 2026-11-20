extends Node2D
class_name PR2LevelDecoder

@onready var lines = $Lines
@onready var stamps = $Stamps
@onready var texts = $Texts

var pr2_objects: Dictionary = {
	0: {"type": "stamp", "name": "tree_stamp", "compat_id": "tree"},
	1: {"type": "stamp", "name": "tree2_stamp", "compat_id": "tree2"},
	2: {"type": "stamp", "name": "tree3_stamp", "compat_id": "tree3"},
	3: {"type": "stamp", "name": "petrified_tree_stamp", "compat_id": "petrifiedtree"},
	4: {"type": "stamp", "name": "cactus_stamp", "compat_id": "pr2_cactus"},
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
	201: {"type": "background", "name": "BG1", "compat_id": "pr2_field"},
	202: {"type": "background", "name": "BG2", "compat_id": "pr2_generic"},
	203: {"type": "background", "name": "BG3", "compat_id": "pr2_lake"},
	204: {"type": "background", "name": "BG4", "compat_id": "pr2_desert"},
	205: {"type": "background", "name": "BG5", "compat_id": "pr2_dots"},
	206: {"type": "background", "name": "BG6", "compat_id": "pr2_space"},
	207: {"type": "background", "name": "BG7", "compat_id": "pr2_skyscraper"},
	300: {"type": "text", "name": "text_code"}
}
var pr2_to_pr4_scale_ratio: float = 128.0 / 30.0
var seg_size: int = 30
var shift_to_default_position: Vector2 = Vector2(-447.0, -337.0)
var start_positions: Array = [] # first 4 blocks in blockstring are always start positions, but using a trick, a block can
# be placed on them if the relative coords land on those blocks' position. this is included in the exported level dict to
# let level decoder know to make start positions there


func clear():
	for child in lines.get_children():
		child.free()
	for child in stamps.get_children():
		child.free()
	for child in texts.get_children():
		child.free()


func is_pr2_level(pr2_level: String) -> bool:
	var sanity_check = false
	var hash_pos = pr2_level.length() - 32
	var hashless_pr2_level = pr2_level.substr(0, hash_pos)
	var split_pr2_level = Array(hashless_pr2_level.split("&"))
	if split_pr2_level.size() > 0:
		var has_data = false
		var data_string
		for string in split_pr2_level:
			if string.begins_with("data="):
				has_data = true
				data_string = string
				break
		if has_data == true:
			var data = data_string.trim_prefix("data=").split("`")
			if data.size() >= 10 and data.size() <= 14:
				sanity_check = true
	return sanity_check


func decode_pr2_level(pr2_level: String) -> Dictionary:
	if !is_pr2_level(pr2_level):
		PopupManager.add_message_popup("Error loading PR2 level. :(\n\nCheck to make sure the file you clicked on is a valid PR2 level in .txt format and try again.", Main.instance.current_scene)
		return {}
	clear()
	var decoded_level = {}
	var hash_pos = pr2_level.length() - 32
	var hashless_pr2_level = pr2_level.substr(0, hash_pos)
	var pr2_level_data_array = hashless_pr2_level.split("&")
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
			data_array[0] = data_array[0].hex_to_int()
			if version == "m1":
				if data_array.get(1) != null and data_array.get(1) != "":
					data_array[1] = decode_objectstring(data_array[1])
				if data_array.get(2) != null and data_array.get(2) != "":
					data_array[2] = decode_objectstring(data_array[2])
				if data_array.get(3) != null and data_array.get(3) != "":
					data_array[3] = decode_objectstring(data_array[3])
				if data_array.get(4) != null and data_array.get(4) != "":
					data_array[4] = decode_objectstring(data_array[4])
				decoded_level = convert_pr2_level_to_pr4(pr2_level_data, data_array)
			elif version == "m2" or version == "m3" or version == "m4":
				if version == "m2":
					if data_array.get(1) != null and data_array.get(1) != "":
						data_array[1] = decode_objectstring2(data_array[1])
				elif version == "m3":
					if data_array.get(1) != null and data_array.get(1) != "":
						data_array[1] = decode_objectstring2(data_array[1], seg_size)
				else:
					if data_array.get(1) != null and data_array.get(1) != "":
						data_array[1] = decode_blockstring(data_array[1])
				if data_array.get(2) != null and data_array.get(2) != "":
					data_array[2] = decode_objectstring2(data_array[2])
				if data_array.get(3) != null and data_array.get(3) != "":
					data_array[3] = decode_objectstring2(data_array[3])
				if data_array.get(4) != null and data_array.get(4) != "":
					data_array[4] = decode_objectstring2(data_array[4])
				if data_array.get(9) != null and data_array.get(9) != "":
					data_array[9] = decode_objectstring2(data_array[9])
				if data_array.get(10) != null and data_array.get(10) != "":
					data_array[10] = decode_objectstring2(data_array[10])
				decoded_level = convert_pr2_level_to_pr4(pr2_level_data, data_array)
	clear()
	return decoded_level


func decode_objectstring(objectstring: String) -> String:
	var loc_7: int = 0
	var loc_8: int = NAN
	var loc_9: int = NAN
	var loc_10: int = NAN
	var loc_11: int = NAN
	var loc_2: Array = Array(objectstring.split(","))
	var loc_3: Array = loc_2.pop_front().split(";")
	var loc_4: int = loc_3[0].hex_to_int()
	var loc_5: int = loc_3[1].hex_to_int()
	var loc_6: int = 0
	while loc_6 < loc_2.size():
		loc_3 = loc_2[loc_6].split(";")
		loc_7 = loc_3[0].hex_to_int()
		loc_8 = loc_3[1].hex_to_int() + loc_4
		loc_9 = loc_3[2].hex_to_int() + loc_5
		loc_2[loc_6] = "o" + str(loc_7) + ";" + str(loc_8) + ";" + str(loc_9)
		if loc_3.get(3) != null:
			loc_10 = int(loc_3[3].hex_to_int() / 100)
			loc_11 = int(loc_3[4].hex_to_int() / 100)
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
	var loc_5: Array = [] if objectstring == null or objectstring == "" else Array(objectstring.split(","))
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
	var loc_2: Array = [] if blockstring == "" else blockstring.split(",")
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
			loc_2[loc_7] = "o" + str(loc_4) + ";" + str(loc_5 * seg_size) + ";" + str(loc_6 * seg_size) + str(loc_11)
			loc_7 += 1
		loc_3 = ",".join(loc_2)
	return loc_3


func convert_pr2_blocks_to_pr4(pr2_block_string: String) -> Dictionary:
	var save_string = ""
	var chunk_map = {}
	var chunks = []
	var pr2_block_string_array = Array(pr2_block_string.split(","))
	var compat_pr2_block_string_array = []
	var array_counter = 0
	var level_encoder = LevelEncoder.new()
	if pr2_block_string_array.size() > level_encoder.mega_chunk_size:
		while level_encoder.mega_chunk_size * array_counter < pr2_block_string_array.size():
			compat_pr2_block_string_array.append(pr2_block_string_array.slice(level_encoder.mega_chunk_size * array_counter, level_encoder.mega_chunk_size * (array_counter + 1)))
			array_counter += 1
	else:
		compat_pr2_block_string_array = [pr2_block_string_array]
	var chunk_coords: Vector2i = Vector2i(shift_to_default_position)
	var block_id = 0
	for compat_block_strings in compat_pr2_block_string_array:
		chunks = []
		chunk_map = {}
		for block_string in compat_block_strings:
			if block_string != "":
				var block_code_array = Array(block_string.split(";"))
				if block_code_array.get(0) != null and block_code_array[0].begins_with("o"):
					block_code_array[0] = block_code_array[0].substr(1)
					block_id = int(block_code_array[0]) + 100 if int(block_code_array[0]) < 100 else int(block_code_array[0])
					var start_positions_blocks = [112, 113, 114]
					if block_id in start_positions_blocks:
						block_id = 111
					chunk_coords = Vector2i((int(block_code_array[1]) / seg_size) + int(shift_to_default_position.x), (int(block_code_array[2]) / seg_size) + int(shift_to_default_position.y))
					if pr2_objects.has(block_id) and pr2_objects[block_id].type == "block":
						var converted_block_id = str(block_id - 99)
						var settings = ConfigurableBlockSettings.new()
						settings.import_settings(BlockManager._block_lookup[converted_block_id].settings)
						if block_code_array[0] == "110" or block_code_array[0] == "125":
							var side_setting = settings.bump.get_type().duplicate(true)
							side_setting.params = {"item_array": Items.convert_pr2_items([1, 2, 3, 4, 5, 6, 7, 8, 9])}
							settings.bump.set_type(side_setting)
						if block_code_array.size() > 3 and block_code_array.get(3) != null:
							if block_id == 110 or block_id == 125:
								var items = []
								items = Array(block_code_array[3].split("-")).duplicate(true)
								var converted_items = []
								for item in items:
									if item.is_valid_int():
										converted_items.append(int(item))
									else:
										converted_items.append(item)
								converted_items = Items.convert_pr2_items(converted_items)
								converted_items.sort()
								var side_setting = settings.bump.get_type().duplicate(true)
								side_setting.params = {"item_array": converted_items}
								settings.bump.set_type(side_setting)
							elif block_id == 126 or block_id == 127:
								var amount = 5 if block_code_array.get(3) == null else int(block_code_array[3])
								var side_setting = settings.bump.get_type().duplicate(true)
								side_setting.params = {"amount": amount}
								settings.bump.set_type(side_setting)
							elif block_id == 131:
								var reset = true if block_code_array.get(3) == "reset" else false
								var stats = [] if reset else Array(block_code_array[3].split("-"))
								var speed = 50 if stats.get(0) == null else int(stats[0])
								var accel = 50 if stats.get(1) == null else int(stats[1])
								var jump = 50 if stats.get(2) == null else int(stats[2])
								var side_setting = settings.bump.get_type().duplicate(true)
								side_setting.params = {"reset": reset, "speed": speed, "accel": accel, "jump": jump}
								settings.bump.set_type(side_setting)
							elif block_id == 132:
								var color = get_color(int(block_code_array[3])).to_html(false)
								settings.teleport_color = color
						var block_edited_settings = settings.get_edited_settings()
						var chunk_x = floori(chunk_coords.x / 8.0) * 8
						var chunk_y = floori(chunk_coords.y / 8.0) * 8
						var pos = (chunk_coords.y - chunk_y) * 8 + (chunk_coords.x - chunk_x)
						var chunk_id = str(chunk_x) + "," + str(chunk_y)
						var existing_chunk = chunk_map.get(chunk_id)
						var chunk: Dictionary
						if existing_chunk:
							chunk = existing_chunk
						else:
							var data = []
							data.resize(8 * 8)
							data.fill({})
							chunk = {
								"x": chunk_x,
								"y": chunk_y,
								"width": 8,
								"height": 8,
								"data": data
							}
							chunks.push_back(chunk)
							chunk_map[chunk_id] = chunk
						chunk.data[pos] = {"id": converted_block_id}
						if !block_edited_settings.is_empty():
							chunk.data[pos]["edited_settings"] = block_edited_settings

		if save_string != "":
			save_string = save_string + "`" + JSON.stringify(chunks)
		else:
			save_string = save_string + JSON.stringify(chunks)
	return {
				"name": "Blocks",
				"chunks": save_string,
				"tile_map_rotation": 0,
				"z_axis": 10,
				"anchor": {"x": 0.0, "y": 0.0},
				"z_index": 10
			}


func convert_drawbg(pr2_drawbg_string: String, layer_scale: float = 1.0):
	var brush_position = Vector2(0.0, 0.0)
	var brush_size: float = 4.0 * pr2_to_pr4_scale_ratio
	var brush_color: Color = Color("000000")
	var mode = "draw"
	var pr2_drawbg_string_array = Array(pr2_drawbg_string.split(","))
	var stamp = preload("res://engine/stamp/stamp.tscn")
	var text = preload("res://engine/textbox.tscn")
	var object_position = null
	# shift drawbg to default camera position
	for drawbg_string in pr2_drawbg_string_array:
		var drawbg_code = drawbg_string.substr(0, 1)
		var drawbg_params = drawbg_string.substr(1)
		var draw_lines = []
		if drawbg_code.begins_with("d"):
			var stroke_array = Array(drawbg_params.split(";"))
			brush_position = Vector2((((float(stroke_array[0]) / seg_size) + shift_to_default_position.x) * seg_size) * pr2_to_pr4_scale_ratio, (((float(stroke_array[1]) / seg_size) + shift_to_default_position.y) * seg_size) * pr2_to_pr4_scale_ratio) * layer_scale
			var stroke_position = Vector2(0.0, 0.0)
			var stroke_increment: int = 2
			draw_lines.append(stroke_position)
			while stroke_increment < stroke_array.size():
				stroke_position += Vector2(float(stroke_array[stroke_increment]) * pr2_to_pr4_scale_ratio, float(stroke_array[stroke_increment + 1]) * pr2_to_pr4_scale_ratio) * layer_scale
				draw_lines.append(stroke_position)
				stroke_increment += 2
		elif drawbg_code.begins_with("c"):
			brush_color = get_color(drawbg_params.hex_to_int())
		elif drawbg_code.begins_with("t"):
			brush_size = float(drawbg_params) * pr2_to_pr4_scale_ratio
		elif drawbg_code.begins_with("m"):
			mode = drawbg_params
		elif drawbg_code.begins_with("o"):
			var object_array = Array(drawbg_params.split(";"))
			var object_id = pr2_objects.get(int(object_array.get(0)))
			if object_id != null and (object_id.type == "stamp" or object_id.type == "block"):
				if object_position == null:
					object_position = Vector2((((float(object_array.get(1)) / seg_size) + shift_to_default_position.x) * seg_size) * pr2_to_pr4_scale_ratio, (((float(object_array.get(2)) / seg_size) + shift_to_default_position.x) * seg_size) * pr2_to_pr4_scale_ratio)
				else:
					object_position += Vector2(float(object_array.get(1)) * pr2_to_pr4_scale_ratio, float(object_array.get(2)) * pr2_to_pr4_scale_ratio)
				var object_scale = Vector2(1.0, 1.0)
				if StampManager._stamp_lookup.has(object_id.compat_id) and StampManager._stamp_lookup[object_id.compat_id]["settings"].has("pr2_scale"):
					object_scale *= Vector2(StampManager._stamp_lookup[object_id.compat_id]["settings"].pr2_scale.x, StampManager._stamp_lookup[object_id.compat_id]["settings"].pr2_scale.y)
				if (object_array.get(3) != null and object_array.get(3).is_valid_float()) and (object_array.get(4) != null and object_array.get(4).is_valid_float()):
					object_scale *= Vector2(float(object_array.get(3)), float(object_array.get(4)))
				#if layer_scale != 0.0:
					#object_position /= layer_scale
					#object_scale /= layer_scale
				var stamp_object = stamp.instantiate()
				stamp_object.set_stamp_properties({"id": object_id.compat_id, "position": {"x": object_position.x, "y": object_position.y}, "scale": {"x": object_scale.x, "y": object_scale.y}})
				stamps.add_child(stamp_object)
				#stamp_object.set_stamp_scale(object_scale)
		elif drawbg_code.begins_with("u"):
			var text_array = Array(drawbg_params.split(";"))
			var text_string = parse_text(text_array.get(0))
			if object_position == null:
				object_position = Vector2((((int(text_array.get(1)) / seg_size) + shift_to_default_position.x) * seg_size) * pr2_to_pr4_scale_ratio, (((int(text_array.get(2)) / seg_size) + shift_to_default_position.x) * seg_size) * pr2_to_pr4_scale_ratio)
			else:
				object_position += Vector2(int(text_array.get(1)) * pr2_to_pr4_scale_ratio, int(text_array.get(2)) * pr2_to_pr4_scale_ratio)
			var text_color = get_color(int(text_array.get(3)))
			var text_scale = Vector2(float(text_array.get(4)) / 100.0, float(text_array.get(5)) / 100.0)
			#if layer_scale != 0.0:
				#object_position /= layer_scale
				#text_scale /= layer_scale
			var text_object = text.instantiate()
			texts.add_child(text)
			text_object.set_text_properties({"text": text_string, "font": "verdana", "font_size": 36, "position": {"x": object_position.x, "y": object_position.y}, "scale": {"x": text_scale.x, "y": text_scale.y}, "color": text_color})
		if mode == "erase":
			if !draw_lines.is_empty():
				var line2d = Line2D.new()
				lines.add_child(line2d)
				line2d.position = brush_position
				line2d.add_point(Vector2(0.0, 0.0))
				line2d.points = PackedVector2Array(draw_lines)
				line2d.end_cap_mode = Line2D.LINE_CAP_ROUND
				line2d.begin_cap_mode = Line2D.LINE_CAP_ROUND
				line2d.width = brush_size
				line2d.default_color = Color("ffffffff")
				line2d.material = CanvasItemMaterial.new()
				line2d.material.blend_mode = CanvasItemMaterial.BLEND_MODE_SUB
				draw_lines = []
		if mode == "draw":
			if !draw_lines.is_empty():
				var line2d = Line2D.new()
				lines.add_child(line2d)
				line2d.position = brush_position
				line2d.points = PackedVector2Array(draw_lines)
				line2d.end_cap_mode = Line2D.LINE_CAP_ROUND
				line2d.begin_cap_mode = Line2D.LINE_CAP_ROUND
				line2d.width = brush_size
				line2d.default_color = brush_color
				line2d.material = CanvasItemMaterial.new()
				line2d.material.blend_mode = CanvasItemMaterial.BLEND_MODE_MIX
				draw_lines = []


func convert_objbg(pr2_objbg_string: String, layer_scale: float = 1.0):
	var pr2_objbg_string_array = Array(pr2_objbg_string.split(","))
	var objects_array = []
	var stamp = preload("res://engine/stamp/stamp.tscn")
	var text = preload("res://engine/textbox.tscn")
	var object_position = null
	for objbg_string in pr2_objbg_string_array:
		var objbg_code = objbg_string.substr(0, 1)
		var objbg_params = objbg_string.substr(1)
		if objbg_code.begins_with("o"):
			var object_array = Array(objbg_params.split(";"))
			var object_id = pr2_objects.get(int(object_array.get(0)))
			if object_id != null and (object_id.type == "stamp" or object_id.type == "block"):
				if object_position == null:
					object_position = Vector2((((float(object_array.get(1)) / seg_size) + shift_to_default_position.x) * seg_size) * pr2_to_pr4_scale_ratio, (((float(object_array.get(2)) / seg_size) + shift_to_default_position.x) * seg_size) * pr2_to_pr4_scale_ratio)
				else:
					object_position += Vector2(float(object_array.get(1)) * pr2_to_pr4_scale_ratio, float(object_array.get(2)) * pr2_to_pr4_scale_ratio)
				var object_scale = Vector2(1.0, 1.0)
				if StampManager._stamp_lookup.has(object_id.compat_id) and StampManager._stamp_lookup[object_id.compat_id]["settings"].has("pr2_scale"):
					object_scale *= Vector2(StampManager._stamp_lookup[object_id.compat_id]["settings"].pr2_scale.x, StampManager._stamp_lookup[object_id.compat_id]["settings"].pr2_scale.y)
				if (object_array.get(3) != null and object_array.get(3).is_valid_float()) and (object_array.get(4) != null and object_array.get(4).is_valid_float()):
					object_scale *= Vector2(float(object_array.get(3)), float(object_array.get(4)))
				#if layer_scale != 0.0:
					#object_position /= layer_scale
					#object_scale /= layer_scale
				var stamp_object = stamp.instantiate()
				stamp_object.set_stamp_properties({"id": object_id.compat_id, "position": {"x": object_position.x, "y": object_position.y}, "scale": {"x": object_scale.x, "y": object_scale.y}})
				stamps.add_child(stamp_object)
				#stamp_object.set_stamp_scale(object_scale)
		elif objbg_code.begins_with("m"):
			var object_array = Array(objbg_params.split(";"))
			var stamp_object = objects_array.get(int(object_array.get(0)))
			if stamp_object != null:
				stamp_object.position = Vector2((((float(object_array.get(1)) / seg_size) + shift_to_default_position.x) * seg_size) * pr2_to_pr4_scale_ratio, (((float(object_array.get(2)) / seg_size) + shift_to_default_position.x) * seg_size) * pr2_to_pr4_scale_ratio)
		elif objbg_code.begins_with("d"):
			var stamp_object = objects_array.get(int(objbg_params))
			if stamp_object:
				stamp_object.free()
		elif objbg_code.begins_with("r"):
			var object_array = Array(objbg_params.split(";"))
			var object_id = pr2_objects.get(int(object_array.get(0)))
			var stamp_object = objects_array.get(int(object_array.get(0)))
			if stamp_object != null:
				stamp_object.scale = Vector2(float(object_array.get(1) / 100), float(object_array.get(2) / 100))
				if StampManager._stamp_lookup.has(object_id.compat_id) and StampManager._stamp_lookup[object_id.compat_id]["settings"].has("pr2_scale"):
					stamp_object.scale *= StampManager._stamp_lookup[object_id.compat_id]["settings"].pr2_scale.x
					stamp_object.scale *= StampManager._stamp_lookup[object_id.compat_id]["settings"].pr2_scale.y
				#if layer_scale != 0.0:
					#stamp_object.scale /= layer_scale
				stamp_object.scale *= pr2_to_pr4_scale_ratio
		elif objbg_code.begins_with("u"):
			var object_array = Array(objbg_params.split(";"))
			var text_string = parse_text(object_array.get(0))
			if object_position == null:
				object_position = Vector2((((int(object_array.get(1)) / seg_size) + shift_to_default_position.x) * seg_size) * pr2_to_pr4_scale_ratio, (((int(object_array.get(2)) / seg_size) + shift_to_default_position.x) * seg_size) * pr2_to_pr4_scale_ratio)
			else:
				object_position += Vector2(int(object_array.get(1)) * pr2_to_pr4_scale_ratio, int(object_array.get(2)) * pr2_to_pr4_scale_ratio)
			var text_color = get_color(int(object_array.get(3)))
			var text_scale = Vector2(float(object_array.get(4)) / 100.0, float(object_array.get(5)) / 100.0)
			#if layer_scale != 0.0:
				#object_position /= layer_scale
				#text_scale /= layer_scale
			var text_object = text.instantiate()
			texts.add_child(text)
			text_object.set_text_properties({"text": text_string, "font": "verdana", "font_size": 36, "position": {"x": object_position.x, "y": object_position.y}, "scale": {"x": text_scale.x, "y": text_scale.y}, "color": text_color})
			objects_array.push_back(text_object)
		elif objbg_code.begins_with("y"):
			var object_array = Array(objbg_params.split(";"))
			var text_object = objects_array.get(int(object_array.get(0)))
			if text_object and text_object.has_method("set_text_properties"):
				var text_string = parse_text(object_array.get(1))
				var text_color = get_color(("0x" + object_array.get(2)).hex_to_int())
				text_object.set_text_string(text_string)
				text_object.set_text_color(text_color)


func convert_pr2_art_to_pr4(pr2_drawbg_string: String, pr2_objbg_string: String, layer_z_axis: float, layer_z_index: int, layer_name: String = "Layer 1"):
	clear()
	convert_drawbg(pr2_drawbg_string, layer_z_axis / 10.0)
	convert_objbg(pr2_objbg_string, layer_z_axis / 10.0)
	return {
		"name": layer_name,
		"lines": GeneralEncoder.new_encode_lines(lines),
		"stamps": GeneralEncoder.new_encode_stamps(stamps),
		"texts": GeneralEncoder.new_encode_texts(texts),
		"rotation": 0,
		"z_axis": layer_z_axis,
		"depth": layer_z_axis,
		"alpha": 100,
		"anchor": {"x": 0.0, "y": 0.0},
		"z_index": layer_z_index
	}


func convert_pr2_level_to_pr4(pr2_level_data: Dictionary, pr2_level_data_array: Array) -> Dictionary:
	var converted_map_layers = []
	var converted_art_layers = []
	converted_map_layers.append(convert_pr2_blocks_to_pr4(pr2_level_data_array[1]))
	converted_art_layers.append(convert_pr2_art_to_pr4(pr2_level_data_array[5], pr2_level_data_array[2], 10.0, 10, "Art 1"))
	converted_art_layers.append(convert_pr2_art_to_pr4(pr2_level_data_array[6], pr2_level_data_array[3], 5.0, 10, "Art 2"))
	converted_art_layers.append(convert_pr2_art_to_pr4(pr2_level_data_array[7], pr2_level_data_array[4], 2.5, 10, "Art 3"))
	if pr2_level_data_array.get(9) != null:
		converted_art_layers.append(convert_pr2_art_to_pr4(pr2_level_data_array[11], pr2_level_data_array[9], 10.0, 11, "Art 0"))
	if pr2_level_data_array.get(10) != null:
		converted_art_layers.append(convert_pr2_art_to_pr4(pr2_level_data_array[12], pr2_level_data_array[10], 20.0, 11, "Art 00"))
	return {
		"title": pr2_level_data.get("title", "pr2_level"),
		"description": pr2_level_data.get("note", ""),
		"map_layers": converted_map_layers,
		"art_layers": converted_art_layers,
		"properties": {
			"background": "blank" if pr2_level_data_array[8] == null or pr2_level_data_array[8] in ["-1", "Square", ""] or int(pr2_level_data_array[8]) not in pr2_objects else pr2_objects[int(pr2_level_data_array[8])].compat_id,
			"fadeColor": get_color(int(pr2_level_data_array[0])).to_html(false),
			"music": get_music(pr2_level_data.get("music", "random")),
			"level_type": pr2_level_data.get("gameMode", "race"),
			"time": int(pr2_level_data.get("max_time", "120")),
			"gravity": float(pr2_level_data.get("gravity", "1.0")),
			"sfchm_chance": int(pr2_level_data.get("cowboyChance", "0")),
			"wind_chance": 0,
			"snow_chance": 0,
			"alien_chance": 0,
			"items": Items.convert_pr2_items([1, 2, 3, 4, 5, 6, 7, 8, 9]) if pr2_level_data.get("items") == null else Items.convert_pr2_items(get_items(pr2_level_data.get("items", ""))),
			"game_config_overrides": {}
		},
	}


func parse_text(unparsed_text: String) -> String:
	unparsed_text.replace("#96", "`")
	unparsed_text.replace("#38", "&")
	unparsed_text.replace("#44", ",")
	unparsed_text.replace("#59", ";")
	unparsed_text.replace("#43", "+")
	unparsed_text.replace("#45", "-")
	return unparsed_text.replace("#35", "#")


func get_music(id: String = "") -> String:
	match id:
		"0": return "none"
		"1": return "orbital-trance"
		"2": return "code"
		"3": return "paradise-on-e"
		"4": return "crying-soul"
		"5": return "my-vision"
		"6": return "switchblade"
		"7": return "the-wires"
		"8": return "before-mydnite"
		"10": return "broked-it"
		"11": return "hello"
		"12": return "pyrokinesis"
		"13": return "flowerz-n-herbz"
		"14": return "instrumental-4"
		"15": return "prismatic"
		"17": return "toodaloo"
		"18": return "night-shade"
		"19": return "blizzard"
		"20": return "pasture-instrumental"
		"21": return "sunset-raiders"
	return "random"


func get_color(color_int: int) -> Color:
	if color_int >= 0:
		var r = color_int >> 16 & 0xFF
		var g = color_int >> 8 & 0xFF
		var b = color_int & 0xFF
		return Color.from_rgba8(r, g, b)
	else:
		return Color(0, 0, 0)


func get_items(items_string: String) -> Array:
	var item_array = Array(items_string.split("`"))
	for item in item_array.size():
		if item_array[item].is_valid_int():
			item_array[item] = int(item_array[item])
	return item_array
