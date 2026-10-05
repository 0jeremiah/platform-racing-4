extends BlockFreqGroup
class_name MoveBlockFreqGroup


func _init(new_freq: float):
	super(new_freq)


func trigger_interval() -> void:
	for block_list in block_lists:
		block_lists[block_list].assign_move_commands()
	for block_list in block_lists:
		block_lists[block_list].execute_move_commands()


func create_block_list(block: BlockScene) -> BlockList:
	var block_list = MoveBlockList.new(block)
	return block_list
