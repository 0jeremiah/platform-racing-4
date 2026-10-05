extends Node
class_name BlockIntervalManager

static var TYPE_MOVE: int = 0
static var TYPE_CHANGE: int = 1
var step_timer: float = 0.0
var step_freq: float = 0.0
var categories: Array = []
var do_intervals: bool = false


func _init() -> void:
	create_categories()


func _process(delta: float):
	if do_intervals:
		if step_timer + delta >= step_freq:
			step(step_timer + delta)
			step_timer = 0.0
		else:
			step_timer += delta


func get_needed_blocks() -> Array:
	var loc_4: Array = []
	var loc_1: Array = []
	for block_freq_group in categories[TYPE_CHANGE]:
		loc_4 = block_freq_group.get_needed_blocks()
		loc_1.append_array(loc_4)
	return loc_1


func get_group(freq_tick: float, group_type: int, param_3: bool = false) -> BlockFreqGroup:
	var loc_4: Dictionary = categories[group_type]
	var loc_5: BlockFreqGroup = loc_4.get(freq_tick)
	if loc_5 == null and param_3:
		if group_type == TYPE_MOVE:
			loc_5 = MoveBlockFreqGroup.new(freq_tick)
		elif group_type == TYPE_CHANGE:
			loc_5 = ChangeBlockFreqGroup.new(freq_tick)
		loc_4[freq_tick] = loc_5
	return loc_5


func start():
	do_intervals = true


func stop():
	do_intervals = false


func add_block(param_1: BlockScene, param_2: float):
	var loc_3: float = 1.0
	if param_2 == TYPE_MOVE:
		param_1.random_move_pattern = create_rand_pattern()
		loc_3 = param_1.settings.move_tick
	else:
		if param_2 != TYPE_CHANGE:
			push_warning("BlockIntervalManager::add_block() - unknown value for type")
		loc_3 = param_1.settings.change_tick
	var loc_4: BlockFreqGroup = get_group(loc_3, param_2, true)
	loc_4.add_block(param_1)


func clear():
	for category in categories:
		categories.erase(category)
	create_categories()


func create_rand_pattern(param_1: int = 10) -> String:
	var loc_4: int = 0
	var loc_2 = ""
	var loc_3: int = 0
	while loc_3 < param_1:
		loc_4 = randi_range(1, 4)
		match loc_4:
			1: loc_2 = loc_2 + "u"
			2: loc_2 = loc_2 + "d"
			3: loc_2 = loc_2 + "l"
			4: loc_2 = loc_2 + "r"
		loc_3 += 1
	return loc_2


func remove_block(param_1: BlockScene, param_2: int):
	var loc_3: int = 1000
	if param_2 == TYPE_MOVE:
		param_1.random_move_pattern = create_rand_pattern()
		loc_3 = param_1.settings.move_tick * 1000
	else:
		if param_2 != TYPE_CHANGE:
			push_warning("BlockIntervalManager::remove_block() - unknown value for type")
		loc_3 = param_1.settings.change_tick * 1000
	var loc_4: BlockFreqGroup = get_group(loc_3, param_2, true)
	if loc_4:
		loc_4.remove_block(param_1)


func create_categories():
	categories = []
	if categories.size() < TYPE_MOVE + 1:
		categories.resize(TYPE_MOVE + 1)
	categories[TYPE_MOVE] = {}
	if categories.size() < TYPE_CHANGE + 1:
		categories.resize(TYPE_CHANGE + 1)
	categories[TYPE_CHANGE] = {}


func step(elapsed_time: float):
	for category in categories:
		for block_freq_group in category:
			category[block_freq_group].step(elapsed_time)
