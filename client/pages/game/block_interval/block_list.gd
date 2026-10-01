class_name BlockList

var block_array = []
var initialized: bool = false
var block_id: String = ""


func _init(block: BlockScene) -> void:
	block_id = block.id
	if block.settings.temporary:
		pass # some function to connect to when the block is initalized goes here
	else:
		init_list(block)


func remove_block(block: BlockScene) -> void:
	var loc_2: int = block_array.find(block)
	if loc_2 > -1:
		block_array.remove_at(loc_2)


func add_block(block: BlockScene) -> void:
	block_array.push_back(block)


func init_list(block: BlockScene) -> void:
	initialized = true
