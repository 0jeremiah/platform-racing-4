extends Node2D


var hostname: String = ""
func get_base_url() -> String:
	if OS.has_feature('web'):
		if !hostname:
			hostname = JavaScriptBridge.eval('window.location.hostname')
			print("Setting base url hostname: ", hostname)
		return "https://" + hostname
		
	if '--local' in OS.get_cmdline_args() || OS.is_debug_build() || OS.get_environment('PR_ENV') == 'local' ||  OS.has_feature("editor"):
		# return 'http://localhost:8080'
		return 'https://dev.platformracing.com'
	elif '--dev' in OS.get_cmdline_args() || OS.get_environment('PR_ENV') == 'dev':
		return 'https://dev.platformracing.com'
	else:
		return 'https://platformracing.com'


func set_scene(scene_name: String) -> Node:
	return get_node("/root/Main").set_scene(scene_name)


func to_atlas_coords(block_id: int) -> Vector2i:
	if block_id == 0:
		return Vector2(-1, -1)
	var id = block_id - 1
	var x = id % 10
	var y = id / 10
	return Vector2i(x, y)


func to_block_id(atlas_coords: Vector2i) -> int:
	return (atlas_coords.y * 10) + atlas_coords.x + 1


func to_bitmask_32(num: int) -> int:
	if num < 1 or num > 32:
		return 0 # Return 0 for out of range numbers
	return 1 << (num - 1)


func get_depth(node: Node) -> int:
	if node is Layer:
		return node.depth
	return get_depth(node.get_parent())
