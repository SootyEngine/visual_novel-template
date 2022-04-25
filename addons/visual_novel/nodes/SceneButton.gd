@tool
extends BaseButton

@export var path := name:
	set(s):
		path = s
		_update_preview()

@export var as_local_to_scene := false:
	set(s):
		as_local_to_scene = s
		_update_preview()

@export var as_pressed := true:
	set(s):
		as_pressed = s
		_update_preview()

@export var _preview := ""

func _pressed() -> void:
	Sooty.dialogue.try_start(_get_path())

func _update_preview():
	_preview = _get_path()

func _get_path() -> String:
	if as_pressed:
		if as_local_to_scene:
			return VisualNovel._get_scene_flow_path("_pressed/%s" % path)
		else:
			return "/%s/_pressed" % path
	else:
		if as_local_to_scene:
			return VisualNovel._get_scene_flow_path("%s" % path)
		else:
			return "/%s" % path
