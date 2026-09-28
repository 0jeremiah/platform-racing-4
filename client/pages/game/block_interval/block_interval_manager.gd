extends Node

static var TYPE_MOVE: int = 0
static var TYPE_CHANGE: int = 1
var last_ms: int
var step_freq: int = 100
var step_interval: int
var categories: Array = []


func _ready() -> void:
	create_categories()


#func get_needed_blocks() -> Array:
	#var loc_3: ChangeBlockFreqGroup = null
	#var loc_4: Array = []
	#var loc_1: Array = []
	#var loc_2: Array = categories[TYPE_CHANGE]
	#for array in loc_2:
		#for element in array:
			#loc_4 = element.get_needed_blocks()
			#loc_1.append_array(loc_4)
	#return loc_1


#func get_group(block_id: String, group_type: int, param_3: bool = false) -> BlockFreqGroup:
	#var loc_4: Array = categories[group_type]
	#var loc_5: BlockFreqGroup = loc_4.get(block_id)
	#if loc_5 == null and param_3:
		#if group_type == TYPE_MOVE:
			#loc_5 = MoveBlockFreqGroup.new()
			#loc_5.block_id = param_1
		#elif group_type == TYPE_CHANGE:
			#loc_5 = ChangeBlockFreqGroup.new()
			#loc_5.block_id = param_1
		#loc_4[block_id] = loc_5
	#return loc_5


func start():
	last_ms = Time.get_ticks_msec()
	#set_interval()


func create_categories():
	categories = []
	if categories.size() < TYPE_MOVE + 1:
		categories.resize(TYPE_MOVE + 1)
	categories[TYPE_MOVE] = {}
	if categories.size() < TYPE_CHANGE + 1:
		categories.resize(TYPE_CHANGE + 1)
	categories[TYPE_CHANGE] = {}
