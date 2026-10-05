class_name BlockFreqGroup

var elasped_time: float = 0.0
var block_lists: Dictionary = {}
var freq: float = 0.0


func _init(new_freq: float) -> void:
	freq = new_freq


func remove_block(block: BlockScene) -> void:
	var loc_2: BlockList = get_block_list(block)
	loc_2.remove_block(block)


func step(param_1: float) -> void:
	elasped_time += param_1
	if elasped_time >= freq:
		elasped_time -= freq
		trigger_interval()


func create_block_list(block: BlockScene) -> BlockList:
	var new_block_list = BlockList.new(block)
	return new_block_list


func get_block_list(block: BlockScene) -> BlockList:
	var loc_2: String = block.id
	var loc_3: BlockList = block_lists.get(loc_2)
	if loc_3 == null:
		loc_3 = create_block_list(block)
		block_lists[loc_2] = loc_3
	return loc_3


func add_block(block: BlockScene) -> void:
	if block.settings.temporary:
		pass
	var loc_2: BlockList = get_block_list(block)
	loc_2.add_block(block)


func trigger_interval() -> void:
	pass
