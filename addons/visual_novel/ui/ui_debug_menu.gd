extends CanvasLayer

var debug_menu: Node

func _ready() -> void:
	visible = false
	Sooty.mods.loaded.connect(_hide)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_debug") and VisualNovel.debug.allow_debug_menu:
		if debug_menu:
			_hide()
		else:
			_show()

func _hide():
	visible = false
	if debug_menu:
		debug_menu.queue_free()
		debug_menu = null
	get_tree().paused = false

func _show():
	visible = true
	Global.snap_screenshot()
	var prefab: PackedScene = load("res://addons/visual_novel/ui/debug_ui.tscn")
	debug_menu = prefab.instantiate()
	debug_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(debug_menu)
	get_tree().paused = true
