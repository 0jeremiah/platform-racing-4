extends Node2D
class_name StampDecoder


func decode(stamp: Dictionary) -> void:
	var stamp_art_layers = stamp.custom_image.get("art_layers", [])
	if stamp_art_layers.is_empty():
		stamp_art_layers.append({
			"name": "Layer 1",
			"lines": [],
			"stamps": [],
			"texts": [],
			"rotation": 0.0,
			"alpha": 100,
			"anchor": {"x": 0.0, "y": 0.0}
		})
		
	for encoded_art_layer in stamp_art_layers:
		# Emit add layer event
		emit_signal("editor_event", {
			"type": EditorEvents.ADD_ART_LAYER,
			"name": encoded_art_layer.name,
			"art_rotation": encoded_art_layer.get("art_rotation", 0),
			"alpha": encoded_art_layer.get("alpha", 100),
			"anchor": encoded_art_layer.get("anchor", {"x": 0, "y": 0})
		})
		
		if encoded_art_layer.get("lines"):
			GeneralDecoder.decode_lines(encoded_art_layer.name, encoded_art_layer.lines)
		if encoded_art_layer.get("stamps"):
			GeneralDecoder.decode_stamps(encoded_art_layer.name, encoded_art_layer.stamps)
		if encoded_art_layer.get("texts"):
			GeneralDecoder.decode_texts(encoded_art_layer.name, encoded_art_layer.texts)
