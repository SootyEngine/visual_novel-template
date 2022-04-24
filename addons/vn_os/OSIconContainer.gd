@tool
extends Control

@export var can_drag := false
@export var double_click := true

@export var cell_size := Vector2(32, 32):
	set(s):
		cell_size = s
		_update_children()

@export var snap_icons := true:
	set(s):
		snap_icons = s
		_update_children()

var _last_click_time := 0.0
var _last_selected: Control = null

func _ready() -> void:
	child_entered_tree.connect(_icon_added)
	child_exited_tree.connect(_icon_removed)
	
	for icon in get_children():
		icon.pressed.connect(_icon_pressed.bind(icon))

func _icon_added(icon: Control):
	icon.pressed.connect(_icon_pressed.bind(icon))
	print("connect ", icon)
	_update_children()

func _icon_removed(icon: Control):
	_update_children()

func _icon_pressed(icon: Control):
	if _last_selected and _last_selected != icon:
		_last_selected.selected = false
	
	icon.selected = true
	
	if double_click:
		if _last_selected == icon and (Time.get_ticks_msec()-_last_click_time) <= 500:
			icon_select(icon)
	else:
		icon_select(icon)
	
	_last_selected = icon
	_last_click_time = Time.get_ticks_msec()

func icon_select(icon: Control):
	find_parent("os").click_file(icon.file_path)
#	get_tree().get_first_node_in_group("os").click_file(icon.file)

func _update_children():
	if snap_icons:
		var pos := Vector2.ZERO
		for child in get_children():
			child.position = pos
			pos.x += cell_size.x
			if pos.x > size.x:
				pos.x = 0
				pos.y += cell_size.y
