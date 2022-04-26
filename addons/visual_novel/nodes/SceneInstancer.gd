extends CanvasLayer
# Creates a scene as a child.
# Updates when mods are loaded so a mod can replace it.

@export var scene_id := ""
@export var action := ""

func _input(event: InputEvent) -> void:
	if action != "" and event.is_action_pressed(action):
		if get_child_count():
			get_child(0).queue_free()
			visible = false
		
		elif VisualNovel.is_scene():
			Sooty.scenes.show_ui(scene_id, self)
			visible = true
			
		get_viewport().set_input_as_handled()
