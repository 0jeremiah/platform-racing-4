extends Node
## Utility singleton with various helper functions for the game
##
## Provides a collection of helper functions for common operations.

func to_bitmask_32(num: int) -> int:
	if num < 1 or num > 32:
		return 0 # Return 0 for out of range numbers
	return 1 << (num - 1)


func get_depth(node: Node) -> int:
	if node is MapLayer:
		return node.z_axis
	elif node is Character:
		return node.tile_interaction.character_depth
	elif node is EggEnemy:
		return node.egg_depth
	if node.get_parent() != null:
		return get_depth(node.get_parent())
	return 10


func gzip_encode(text: String) -> PackedByteArray:
	var gzip := StreamPeerGZIP.new()
	gzip.start_compression()
	gzip.put_data(text.to_utf8_buffer())
	gzip.finish()
	return gzip.get_data(gzip.get_available_bytes())[1]


func gzip_decode(data: PackedByteArray) -> String:
	var gzip := StreamPeerGZIP.new()
	gzip.start_decompression()
	gzip.put_data(data)
	gzip.finish()
	return gzip.get_utf8_string(gzip.get_available_bytes())
