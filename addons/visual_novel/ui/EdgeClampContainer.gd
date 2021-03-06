@tool
extends Control

enum { TOP_LEFT, TOP, TOP_RIGHT, LEFT, CENTER, RIGHT, BOTTOM_LEFT, BOTTOM, BOTTOM_RIGHT }

@export_enum(TOP_LEFT, TOP, TOP_RIGHT, LEFT, CENTER, RIGHT, BOTTOM_LEFT, BOTTOM, BOTTOM_RIGHT) var edge: int = BOTTOM:
	set(e):
		edge = e
		_resized()

@export var margin := 0.0:
	set(m):
		margin = m
		_resized()

func _ready() -> void:
	resized.connect(_resized)

func _resized():
	if not is_inside_tree():
		return
	
	match edge:
		BOTTOM:
			size.y = 0.0
			hide()
			show()
			var vp := get_viewport_rect()
			position.y = vp.size.y - size.y - margin
