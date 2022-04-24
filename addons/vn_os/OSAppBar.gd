extends Node

@export var _window_container: NodePath
@export var _button_container: NodePath
@export var button_prefab: PackedScene

var _buttons := {}

func _ready() -> void:
	var window_container := get_node(_window_container)
	window_container.child_entered_tree.connect(_window_added)
	window_container.child_exited_tree.connect(_window_removed)

func _changed_title(win: OSAppWindow):
	_buttons[win].text = win.title

# create a button when a window gets added
func _window_added(win: OSAppWindow):
	var btn := button_prefab.instantiate()
	_buttons[win] = btn
	win.changed_title.connect(_changed_title.bind(win))
	get_node(_button_container).add_child(btn)

# remove button when a window closes
func _window_removed(win: Control):
	var btn: Button = _buttons[win]
	_buttons.erase(win)
	btn.queue_free()
