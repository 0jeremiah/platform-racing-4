extends BlockList
class_name MoveBlockList

var pattern_index: int = 0
var max_pattern_index: int = 0
var max_rand_index: int = 0
var rand_index: int = 0
var repeat_counters: Dictionary = {}
var move_pattern: String = ""


func _init(block: BlockScene) -> void:
	super(block)


func assign_move_commands() -> void:
	var loc_1: String = ""
	var loc_2: BlockScene = null
	var loc_3: bool = false
	var loc_4: int = 0
	var loc_5: String = ""
	var loc_6: String = ""
	var loc_7: int = 0
	var loc_8 = 0
	var loc_9: String = ""
	var loc_10: int = 0
	var loc_11: int = 0
	var loc_12: String = ""
	var loc_13: int = 0
	var loc_14: String = ""
	if initialized:
		loc_1 = move_pattern.chr(pattern_index)
		if char_is_numeric(loc_1) and pattern_index > 0:
			loc_3 = false
			loc_4 = pattern_index
			# as3's "do...while" does the do part one time before checking the while condition
			# the code below is slight different from the one in the while function because of this
			loc_4 += 1
			if loc_4 < max_pattern_index:
				loc_5 = move_pattern.chr(loc_4)
			while char_is_numeric(loc_5):
				loc_4 += 1
				if loc_4 >= max_pattern_index:
					break
				loc_5 = move_pattern.chr(loc_4)
			loc_6 = move_pattern.substr(pattern_index, loc_4 - pattern_index)
			loc_7 = int(loc_6)
			if repeat_counters.get(pattern_index) == null:
				repeat_counters[pattern_index] = 0
			loc_8 = int(repeat_counters[pattern_index]) # technically this is already an int but just in case
			# yeah im referecing pr3's code. how could you tell?
			loc_8 = loc_8 + 1
			if loc_8 >= loc_7:
				loc_8 = 0
			else:
				loc_3 = true
			repeat_counters[pattern_index] = loc_8
			if loc_3:
				if loc_9 == ")":
					loc_10 = 0
					loc_11 = 0
					loc_13 = pattern_index - 1
					while loc_13 > 0:
						loc_12 = move_pattern.chr(loc_13)
						if loc_12 == ")":
							loc_10 += 1
						else:
							loc_11 += 1
						if loc_10 == loc_11:
							break
						loc_13 -= 1
					pattern_index = loc_13
				else:
					pattern_index -= 1
			else:
				pattern_index = loc_4
			if pattern_index > max_pattern_index:
				pattern_index = 0
			loc_1 = move_pattern.chr(pattern_index)
		for block_info in block_array:
			var block_node = block_info.tile_map_layer.get_block(block_info.coords).node
			if block_node:
				if loc_1 == "*":
					loc_14 = loc_2.random_move_pattern.chr(rand_index)
					block_node.assign_move_block_command(loc_14)
				else:
					block_node.assign_move_block_command(loc_1)
		if loc_1 == "*":
			rand_index += 1
			if rand_index > max_rand_index:
				rand_index = 0
		pattern_index += 1
		if pattern_index > max_pattern_index:
			pattern_index = 0


func execute_move_commands() -> void:
	if initialized:
		for block in block_array:
			var block_info = block.tile_map_layer.get_block(block.coords)
			if block_info.has("node") and block_info.node != null:
				block_info.node.execute_move_block_command()


func init_list(block: BlockScene) -> void:
	super(block)
	move_pattern = block.settings.move_pattern
	move_pattern.replace("up", "u")
	move_pattern.replace("down", "d")
	move_pattern.replace("right", "r")
	move_pattern.replace("left", "l")
	move_pattern.replace("wait", "-")
	move_pattern.replace("return", "@")
	move_pattern.replace("random", "*")
	if move_pattern == "":
		move_pattern = "*"
	max_pattern_index = move_pattern.length() - 1
	max_rand_index = block.random_move_pattern.length() - 1
	


func char_is_numeric(char: String) -> bool:
	var numbers = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
	return char in numbers
