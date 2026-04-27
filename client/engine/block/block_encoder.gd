extends Node2D
class_name BlockEncoder


func encode(block_layers: Node2D, block_manager: BlockManager) -> Dictionary:
	var block = {
		"title": BlockEditor.current_block_name,
		"description": BlockEditor.current_block_description,
		"settings": {
			"matter_type": "solid",
			"block_type": "active",
			"health": 100,
			"stat_supply": 1,
			"item_supply": 1,
			"left": {"type": "active", "params": {}},
			"right": {"type": "active", "params": {}},
			"top": {"type": "active", "params": {}},
			"bottom": {"type": "active", "params": {}},
			"bump": {"type": "active", "params": {}},
			"stand": {"type": "active", "params": {}},
			"any_side": {"type": "active", "params": {}}
		}#,
		#"custom_image": {
			#"buffer_size": 65536,
			#"size": {"x": 128, "y": 128},
			#"format": 8,
			#"has_mipmaps": false,
			#"compressed_image": [],
			#"art_layers": []
		#}
	}
	#for group_layer in block_layers.art_layers.get_children():
		#if group_layer is ArtLayer:
			#var art_layer = {
				#"name": group_layer.name,
				#"lines": GeneralEncoder.encode_lines(group_layer.lines),
				#"stamps": GeneralEncoder.encode_stamps(group_layer.stamps),
				#"texts": GeneralEncoder.encode_texts(group_layer.texts),
				#"rotation": group_layer.art_rotation,
				#"alpha": group_layer.alpha,
				#"anchor": {"x": group_layer.anchor.x, "y": group_layer.anchor.y},
				#"block_effect_settings": group_layer.block_effect_settings
			#}
			#block.custom_image.block_data.art_layers.push_back(art_layer)
	return block
