extends BlockFreqGroup
class_name ChangeBlockFreqGroup


func _init(new_freq: int):
	super(new_freq)
	elasped_ms = new_freq


func get_needed_blocks() -> Array:
	var needed_blocks = []
	for block_list in block_lists:
		needed_blocks.append_array(block_lists[block_list].get_needed_blocks())
	return needed_blocks


func trigger_interval() -> void:
	for block_list in block_lists:
		block_lists[block_list].execute_change()


func create_block_list(block: BlockScene) -> BlockList:
	var block_list = ChangeBlockList.new(block)
	return block_list
