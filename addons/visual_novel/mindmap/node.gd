extends GraphNode

@export var _richtext: NodePath
@onready var richtext: RichTextLabel2 = get_node(_richtext)

func get_text() -> String:
	return richtext.bbcode

func set_text(text: String):
	richtext.set_bbcode(text)
	
func _on_node_resize_request(new_minsize: Vector2) -> void:
	var graph: GraphEdit = get_parent()
	if graph.use_snap:
		var snap = graph.snap_distance
		new_minsize.x = round(new_minsize.x / snap) * snap
		new_minsize.y = round(new_minsize.y / snap) * snap
	size = new_minsize
	minimum_size = new_minsize

func _on_node_close_request() -> void:
	get_parent().close_node(self)


func set_state(data: Dictionary):
	title = data.title
	comment = data.is_comment
	size = data.size
	position_offset = data.position
	self_modulate = data.get("color", self_modulate)
	set_text(data.text)

func get_state() -> Dictionary:
	return {
		title=title,
		is_comment=comment,
		position=position_offset,
		size=size,
		color=self_modulate,
		text=get_text(),
	}
