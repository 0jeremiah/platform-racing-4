extends Node2D
class_name BlockEncoder


func encode(block_layers: Node2D, block_manager: BlockManager) -> Dictionary:
	var block = {
		"title": BlockEditor.current_block_name,
		"description": BlockEditor.current_block_description,
		"art_layers": [],
		"properties": {}
	}
	for group_layer in block_layers.art_layers.get_children():
		if group_layer is ArtLayer:
			var art_layer = {
				"name": group_layer.name,
				"lines": GeneralEncoder.encode_lines(group_layer.lines),
				"stamps": GeneralEncoder.encode_stamps(group_layer.stamps),
				"texts": GeneralEncoder.encode_texts(group_layer.texts),
				"rotation": group_layer.art_rotation,
				"alpha": group_layer.alpha,
				"anchor": {"x": group_layer.anchor.x, "y": group_layer.anchor.y}
			}
			block.art_layers.push_back(art_layer)
	return block
