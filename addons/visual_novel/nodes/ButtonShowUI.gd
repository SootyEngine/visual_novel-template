extends Button

@export var ui: PackedScene

var showing: Node

func _pressed() -> void:
	if not showing or not showing.is_inside_tree():
		release_focus()
		showing = ui.instantiate()
		get_tree().current_scene.add_child(showing)
	
	else:
		push_error("Scene %s is already being shown.")
