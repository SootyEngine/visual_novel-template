extends Control

var _hiding_mouse := false

func _process(delta: float) -> void:
	var r := get_parent_control().get_global_rect()
	var mp := get_global_mouse_position()
	
	# hide user cursor when hovering pc
	if r.has_point(mp):
		if not _hiding_mouse:
			_hiding_mouse = true
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	# show user cursor otherwise
	else:
		if _hiding_mouse:
			_hiding_mouse = false
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# align to cursor
	if _hiding_mouse:
		global_position.x = clampf(mp.x, r.position.x, r.end.x)
		global_position.y = clampf(mp.y, r.position.y, r.end.y)
