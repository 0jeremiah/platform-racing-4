extends Node2D

@onready var block_graphic = $Node2D/Sprite2D
@onready var stamp_graphic = $Node2D/Sprite2D2
@onready var object_box = $ObjectBox
var example_node = null


func _ready() -> void:
	example_node = stamp_graphic
	object_box.set_object_info({"delete": true, "resize": true, "options": true, "text": false},
	{"type": "stamp", "node": example_node, "position": example_node.global_position,
	"rotation": example_node.rotation_degrees, "offset": example_node.offset,
	"size": example_node.texture.get_size(), "scale": example_node.scale})
