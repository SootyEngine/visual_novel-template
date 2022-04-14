@tool
extends Control

var last_modified := 0
var state := {src={}, ids={}}
var timer := 0.0
var needs_save := false
var is_plugin := false
var pluginref: Node

func _ready() -> void:
	var node = get_node_or_null("Console")
	if node:
		node.meta_clicked.connect(_meta_clicked)
	load_state()

func _process(delta: float) -> void:
	timer -= delta
	if timer <= 0.0:
		timer = 1.0
		if needs_save:
			needs_save = false
			UFile.save_json("user://printer.json", state)
		if get_node_or_null("Console"):
			_scan_file()

func load_state():
	state = UFile.load_json("user://printer.json", state)

func _get_info_from_meta(meta: String) -> Dictionary:
	var p := meta.substr(1).rsplit(" ", true, 1)[0]
	var id := p.substr(0, 2)
	var line: int = p.substr(2).strip_edges().to_int()
	
	# reload if not available
	if not id in state.src:
		load_state()
	
	# convert back to path and line
	var info = state.src[id]
	info.line = line
	return info

func _meta_clicked(meta: String):
	if is_plugin and pluginref:
		var info := _get_info_from_meta(meta)
		pluginref.get_editor_interface().edit_script(load(info.source), info.line)
	
func nt(msg: String):
	var stack = get_stack()
	if not len(stack):
		print(msg)
		return
	
	stack = stack[-2]
	var source = stack.source
	
	var uid: String
	if source in state.ids:
		uid = state.ids[source]
	else:
		seed(hash(source))
		uid = get_uid(state.ids)
		state.ids[source] = uid
		state.src[uid] = stack
		needs_save = true
	
#	state.src[uid].lines[stack.line] = stack.function
	
	# this will be added to the log
	print(":%s%03d %s" % [uid, stack.line, msg])

const CHARS := "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

static func get_uid(keys: Dictionary) -> String:
	var id := get_id()
	while id in keys:
		id = get_id()
	return id

static func get_id() -> String:
	var out := ""
	for i in 2:
		out += CHARS[randi() % len(CHARS)]
	return out

func _scan_file():
	var path := "user://logs/godot.log"
	var time := UFile.get_modified_time(path)
	if time != last_modified:
		last_modified = time
		
		load_state()
		print("loaded")
		
		var lines := Array(UFile.load_text(path).split("\n"))\
			.filter(func(x):
				return x.begins_with(":"))\
			.map(func(x):
				var p := Array(x.split(" ", true, 1))
				var id = p[0].substr(1, 2)
				var line = p[0].substr(3).to_int()
				var info = state.src[id]
				var hint = "%s::%s@%s" % [info.source.get_file(), info.function, line]
				return "[url=%s][hint=%s]%s[/hint][/url]" % [p[0], hint, p[1]])
		
		$Console.text = "\n".join(lines)
