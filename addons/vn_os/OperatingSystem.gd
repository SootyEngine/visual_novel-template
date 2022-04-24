extends Control

@export var _windows: NodePath
@onready var windows: Control = get_node(_windows)
@export var _desktop: NodePath
@onready var desktop: Control = get_node(_desktop)

@onready var background: Control = $"background"
@export var window_template: PackedScene
@export_file("*.soda ; Sooty Data") var data_source: String

var files := {}
var apps := {}
var password := ""

func _ready() -> void:
	var data = DataParser.new().parse(data_source, true).get("data", {})
	files = data.get("files", files)
	apps = data.get("apps", apps)
	password = data.get("password", password)
	
	if "desktop" in data:
		for item in data.desktop:
			add_to_desktop(item)

func is_window_open(id: String) -> bool:
	for win in windows.get_children():
		if win.name == id:
			return true
	return false

func get_window(id: String) -> OSAppWindow:
	for win in windows.get_children():
		if win.name == id:
			return win
	return null

func get_or_create_window(id: String) -> OSAppWindow:
	var win := get_window(id)
	if not win:
		win = _create_window(id)
	return win

func get_file(file_path: String) -> Variant:
	return UDict.get_at(files, file_path.split("/"))

func click_file(file_path: String):
	var file: Variant = get_file(file_path)
	var win: OSAppWindow
	print(file)
	
	if file is String:
		if file.begins_with("res://"):
			match file.get_extension().to_lower():
				"png", "jpg", "webp", "bmp":
					win = get_or_create_window("image_viewer")
				"ogv", "ogg", "mp4", "webm":
					win = get_or_create_window("video_player")
				"txt":
					win = get_or_create_window("text_editor")
				var ext:
					push_error("No app for extension '%s'." % ext)
		else:
			win = get_or_create_window("text_editor")
		
	elif file is Dictionary:
		win = get_or_create_window(file.get("app", ""))
	
	else:
		push_error("Not implemented.")
	
	if win:
		win.set_content_data(file_path, file)

func close_window(window: Control):
	window.queue_free()

func _create_window(id: String) -> OSAppWindow:
	var win: Control = window_template.instantiate()
	win.request.connect(_window_request.bind(win))
	win.name = id
	windows.add_child(win)
	win.global_position = global_position + (size - win.size) * .5
	
	# populate window with content based on app type
	var content_path := "res://addons/sim_os/apps/%s/%s.tscn" % [id, id]
	if UFile.exists(content_path):
		win.set_content(load(content_path).instantiate())
	
	return win

func _window_request(msg: String, payload: Variant, win: Control):
	match msg:
		"close": close_window(win)

func add_to_desktop(file_path: String):
	var file = get_file(file_path)
	var node: Node = load("res://addons/sim_os/windows/file_icon.tscn").instantiate()
	desktop.add_child(node)
	node.name = file_path.get_file()
	node.file_path = file_path
	node.set_data(get_file(file_path))
