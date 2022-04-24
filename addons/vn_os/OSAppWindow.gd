@tool
extends Control
class_name OSAppWindow

signal request(msg: String, payload: Variant)
signal changed_title()

@export var allow_drag := true
@export var allow_resize := true
@export var allow_close := true
@export var allow_minimize := true

@export var show_close := true
@export var show_minimize := true

@export var title := "Window":
	set(c):
		title = c
		changed_title.emit()
		if title_label:
			title_label.set_text(c)

@export var _close_button: NodePath
@onready var close_button: Button = get_node(_close_button)
 
@export var _minimize_button: NodePath
@onready var minimize_button: Button = get_node(_minimize_button)

@export var _title_label: NodePath
@onready var title_label: Label = get_node(_title_label)

@export var _content_container: NodePath
@onready var content_container: Control = get_node(_content_container)
var _dragging := false
var _drag_offset := Vector2.ZERO

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	if close_button:
		if show_close:
			close_button.pressed.connect(_request.bind("close"))
		else:
			close_button.visible = false
	
	if minimize_button:
		if show_minimize:
			minimize_button.pressed.connect(_request.bind("minimize"))
		else:
			minimize_button.visible = false

func set_content(content: Control):
	content.window = self
	content_container.add_child(content)

func set_content_data(file_path: String, file: Variant):
	var content = get_content()
	if content:
		content.file_path = file_path
		content.set_data(file)
		title = content.get_title()
	else:
		push_error("No content for %s %s." % [file_path, file])

func get_content() -> Control:
	return content_container.get_child(0)

func _request(msg: String, payload: Variant = null):
	request.emit(msg, payload)

func _input(e: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	
	if e is InputEventMouseButton:
		var mp := get_global_mouse_position()
		if e.pressed:
			if e.button_index == MOUSE_BUTTON_LEFT:
				if title_label.get_global_rect().has_point(mp):
					_dragging = true
					_drag_offset = global_position - mp
		else:
			if e.button_index == MOUSE_BUTTON_LEFT:
				if _dragging:
					_dragging = false

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	if allow_drag and _dragging:
		_drag_window()

func _drag_window():
	var p := get_global_mouse_position() + _drag_offset
	var r := get_parent_control().get_global_rect()
	p.x = clampf(p.x, r.position.x, r.end.x - size.x)
	p.y = clampf(p.y, r.position.y, r.end.y - size.y)
	global_position = p
