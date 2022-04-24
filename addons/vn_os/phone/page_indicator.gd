@tool
extends Control

@export var pages := 4
@export var current := 1

func _draw():
	
	var middle := size * .5
	var dist := size.y * 3.0
	middle.x -= dist * .5 * (pages - 1)
	
	for i in pages:
		var p := middle + Vector2(i * dist, 0.0)
		if i == current:
			draw_circle(p, size.y * .5, Color.WHITE)
		else:
			draw_circle(p, size.y * .33, Color(1,1,1,.33))
