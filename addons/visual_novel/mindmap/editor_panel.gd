extends Control

@export var _graph: NodePath
@export var _text: NodePath
@export var _title: NodePath
@export var _color: NodePath
@export var _is_comment: NodePath
@onready var graph: GraphEdit = get_node(_graph)
@onready var text: CodeEdit = get_node(_text)
@onready var title: LineEdit = get_node(_title)
@onready var color: ColorPickerButton = get_node(_color)
@onready var is_comment: CheckButton = get_node(_is_comment)

var selected_node: GraphNode

func _ready() -> void:
	set_disabled(true)


func set_disabled(d: bool):
	color.disabled = d
	is_comment.disabled = d
	title.editable = not d
	text.editable = not d

func _on_graph_edit_node_selected(node: Node) -> void:
	await get_tree().process_frame
	set_disabled(false)
	selected_node = node
	color.color = node.self_modulate
	title.text = node.title
	text.text = node.get_text()
	is_comment.button_pressed = node.comment

func _on_graph_edit_node_deselected(node: Node) -> void:
	set_disabled(true)
	selected_node = null
	color.color = Color.BLACK
	title.text = ""
	text.text = ""
	is_comment.button_pressed = false

# change label of node
func _on_title_text_changed(new_text: String) -> void:
	if selected_node:
		selected_node.title = new_text
		graph.mark_for_save()

# change text of node
func _on_code_edit_text_changed() -> void:
	if selected_node:
		selected_node.set_text(text.text)
		graph.mark_for_save()


func _on_is_comment_toggled(button_pressed: bool) -> void:
	if selected_node:
		selected_node.comment = button_pressed
		graph.mark_for_save()


func _on_tint_color_changed(color: Color) -> void:
	if selected_node:
		selected_node.self_modulate = color
		graph.mark_for_save()
