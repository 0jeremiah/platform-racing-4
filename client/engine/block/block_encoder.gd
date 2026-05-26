extends Node2D
class_name BlockEncoder


func encode(_block_settings: ConfigurableBlockSettings, block_layers: Node2D, sub_viewport: SubViewport) -> Dictionary:
	var block = {
		"title": BlockEditor.current_block_name,
		"description": BlockEditor.current_block_description,
		"settings": _block_settings.export_settings(),
		"custom_image": {
			"buffer_size" = sub_viewport.get_texture().get_image().get_data().size(),
			"width" = sub_viewport.get_texture().get_image().get_width(),
			"height" = sub_viewport.get_texture().get_image().get_height(),
			"format" = sub_viewport.get_texture().get_image().get_format(),
			"has_mipmaps" = sub_viewport.get_texture().get_image().has_mipmaps(),
			"custom_image" =  sub_viewport.get_texture().get_image().get_data().compress(sub_viewport.get_texture().get_image().get_format()),
			"art_layers" = []
		}
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
				"anchor": {"x": group_layer.anchor.x, "y": group_layer.anchor.y},
				"block_effect_settings": group_layer.block_effect_settings
			}
			block.custom_image.art_layers.push_back(art_layer)
	return block
