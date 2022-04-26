@tool
extends BaseButton

@export var path: String = str(name):
	set(s):
		path = s
		_update_preview()

@export var local := false:
	set(s):
		local = s
		_update_preview()

@export var _preview := ""

func _pressed() -> void:
	Sooty.dialogue.try_start(_get_path())

func _update_preview():
	_preview = _get_path()

func _get_path() -> String:
	if local:
		return Flow.get_scene_path(path)
	else:
		return path
