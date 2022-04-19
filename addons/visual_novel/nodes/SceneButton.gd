extends BaseButton

@export var id := name
@export var local_to_scene := false
@export var as_pressed := true

func _pressed() -> void:
	var flow: String
	if as_pressed:
		if local_to_scene:
			flow = VisualNovel._get_scene_flow_path("_pressed/%s" % id)
		else:
			flow = "/%s/_pressed" % id
	else:
		if local_to_scene:
			flow = VisualNovel._get_scene_flow_path("%s" % id)
		else:
			flow = "/%s" % id
	Dialogue.goto(flow)
