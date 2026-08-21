extends Lister
class_name Selector

signal node_selected
signal node_clicked

var selected_node = null
var selected_data = null


func click_node(node: Node, data = null):
	if selected_node == node:
		emit_signal("node_clicked", selected_data)
	else:
		deselect()
		selected_node = node
		selected_data = data
		emit_signal("node_selected", selected_data)


func add_node(node: Node):
	list_container.add_child(node)


func add_node_with_select_signal(node: Node, signal_name: String, data = null):
	list_container.add_child(node)
	node.connect(signal_name, click_node.bind(node, data))


func deselect():
	if selected_node != null:
		selected_node = null
		selected_data = null


func get_selected_node() -> Variant:
	return selected_node


func get_selected_data() -> Variant:
	return selected_data
