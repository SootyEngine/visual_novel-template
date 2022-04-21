extends GraphEdit

const SAVE_PATH := "res://debug_output/idea_map.tres"

@export var _popup: NodePath
@onready var popup: PopupMenu = get_node(_popup)

@export var _node_prefab: NodePath
@onready var node_prefab: GraphNode = get_node(_node_prefab)

var clicked_position: Vector2
var save_timer = 0.0
var selected := []
var creation_count := 0

var cursor_connection := {}
var cursor_connection_line: PackedVector2Array = []

func _ready() -> void:
	remove_child(node_prefab)
	popup.index_pressed.connect(_popup_pressed)
	load_map()

func mark_for_save():
	save_timer = 2.0


func _process(delta: float) -> void:
	if save_timer > 0.0:
		save_timer -= delta
		if save_timer <= 0.0:
			save_map()
	check_for_cursor_connection()
	update()


func save_map():
	var node_info := {}
	# save node data
	for node in get_children():
		if node is GraphNode:
			node_info[node.name] = node.get_state()
	
	# save connection data
	var connection_info = get_connection_list()
	var out = {
		nodes=node_info,
		connections=connection_info,
		# save state
		zoom=zoom,
		offset=scroll_offset,
		count=creation_count,
	}
	UFile.save_to_resource(SAVE_PATH, out)
	print("Saved map to %s." % SAVE_PATH)


func load_map():
	var data = UFile.load_from_resource(SAVE_PATH, {})
	if data:
		# create nodes
		for node_name in data.nodes:
			var node_data: Dictionary = data.nodes[node_name]
			var node: GraphNode = _create_node(node_data.position)
			node.set_name(node_name)
			node.set_state(node_data)
		
		await get_tree().process_frame
		
		# create connections
		for c in data.connections:
			connect_node(c.from, c.from_port, c.to, c.to_port)
		
		zoom = data.zoom
		scroll_offset = data.offset
		creation_count = data.get("count", creation_count)
	
	print("Loaded map from %s." % SAVE_PATH)


func _create_node(at: Vector2) -> GraphNode:
	var node: GraphNode = node_prefab.duplicate()
	add_child(node)
	node.name = "n%s" % creation_count
	node.selected = false
	node.position_offset = at
	creation_count += 1
	return node

func remove_node(node: GraphNode):
	# { from_port: 0, from: "GraphNode name 0", to_port: 1, to: "GraphNode name 1" }
	for c in get_connection_list():
		if c.from == node.name or c.to == node.name:
			disconnect_node(c.from, c.from_port, c.to, c.to_port)
	node.queue_free()

func _popup_pressed(index: int):
	# create node from popup
	if index == 0:
		_create_node(clicked_position)
		mark_for_save()

func _on_graph_edit_connection_request(from: StringName, from_slot: int, to: StringName, to_slot: int) -> void:
	connect_node(from, from_slot, to, to_slot)
	mark_for_save()

func _on_graph_edit_disconnection_request(from: StringName, from_slot: int, to: StringName, to_slot: int) -> void:
	disconnect_node(from, from_slot, to, to_slot)
	mark_for_save()

func _on_graph_edit_connection_to_empty(from: StringName, from_slot: int, release_position: Vector2) -> void:
	var node := _create_node(get_mouse() - Vector2(0, 108))
	connect_node(from, from_slot, node.name, from_slot)
	mark_for_save()

func _on_graph_edit_connection_from_empty(to: StringName, to_slot: int, release_position: Vector2) -> void:
	var node := _create_node(get_mouse() - Vector2(200, 108))
	connect_node(node.name, to_slot, to, 0)
	mark_for_save()

func _is_at_line(point: Vector2, points: PackedVector2Array, max_dist: float) -> bool:
	for i in len(points)-1:
		var p := Geometry2D.get_closest_point_to_segment(point, points[i], points[i+1])
		if point.distance_squared_to(p) <= max_dist:
			return true
	return false

func _draw() -> void:
	if cursor_connection:
		draw_polyline(cursor_connection_line, Color.DEEP_SKY_BLUE, 8.0, true)

func check_for_cursor_connection() -> bool:
	cursor_connection_line = []
	cursor_connection = {}
	var cursor := get_local_mouse_position()
	
	for c in get_connection_list():
		# { from_port: 0, from: "GraphNode name 0", to_port: 1, to: "GraphNode name 1" }
		var from: GraphNode = get_node(NodePath(c.from))
		var from_pos := from.get_connection_output_position(c.from_port)
		var to: GraphNode = get_node(NodePath(c.to))
		var to_pos := to.get_connection_input_position(c.to_port)
		
		from_pos += from.position_offset * zoom - scroll_offset
		to_pos += to.position_offset * zoom - scroll_offset
		
		var points := get_connection_line(from_pos, to_pos)
		if _is_at_line(cursor, points, 32.0):
			cursor_connection_line = points
			cursor_connection = c
			return true
	
	return false

func _on_graph_edit_popup_request(position: Vector2) -> void:
	if cursor_connection:
		var c := cursor_connection
		disconnect_node(c.from, c.from_port, c.to, c.to_port)
		mark_for_save()
	
	else:
		clicked_position = get_mouse()
		popup.position = position
		popup.size = Vector2.ZERO
		popup.popup()
		get_viewport().set_input_as_handled()

func get_mouse() -> Vector2:
	return (get_local_mouse_position() + scroll_offset) / zoom


func _on_graph_edit_delete_nodes_request() -> void:
	for node in selected:
		remove_node(node)
	selected.clear()
	mark_for_save()

func _on_graph_edit_node_deselected(node: Node) -> void:
	if node in selected:
		selected.erase(node)

var _motion: Tween
var _selected_time := 0.0
func _on_graph_edit_node_selected(node: Node) -> void:
	var current_time := Time.get_ticks_msec()
	
	# add to selection list
	if not node in selected:
		selected.append(node)
	
	# if double clicking, scroll camera
	elif current_time - _selected_time <= 500:
		var dest = (node.position_offset+node.size*.5)*zoom - size * .5
		_motion = get_tree().create_tween()
		_motion.bind_node(self)
		_motion.tween_property(self, "scroll_offset", dest, 0.25)\
			.set_ease(Tween.EASE_IN_OUT)\
			.set_trans(Tween.TRANS_QUAD)
	
	_selected_time = current_time


func _on_graph_edit_end_node_move() -> void:
	mark_for_save()
