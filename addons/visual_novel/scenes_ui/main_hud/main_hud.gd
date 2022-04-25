extends Control

var _tween: Tween
var _shown := true

func _ready() -> void:
	Sooty.dialogue.started.connect(_hide)
	Sooty.dialogue.ended.connect(_show)
	Sooty.scenes.changed.connect(_scene_changed)
	if Sooty.dialogue.is_active():
		_hide()

func _scene_changed():
	if get_tree().current_scene is Scene:
		_show()
	else:
		_hide()

func _init_tween():
	if _tween:
		_tween.kill()
	_tween = get_tree().create_tween()
	_tween.bind_node(self)
	_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)

func _hide():
	if _shown:
		_shown = false
		_init_tween()
		_tween.tween_property(self, "modulate:a", 0.0, 0.25)
		_tween.tween_callback(set_visible.bind(false))

func _show():
	if not _shown:# and get_tree().current_scene is Scene:
		_shown = true
		_init_tween()
		_tween.tween_callback(set_visible.bind(true))
		_tween.tween_property(self, "modulate:a", 1.0, 0.25)
