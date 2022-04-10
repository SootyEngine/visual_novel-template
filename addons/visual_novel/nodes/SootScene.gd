@tool
extends Node
class_name SootScene

var id: String:
	get: return UFile.get_file_name(scene_file_path)

@export_file("*.soot;Soot File") var soot_path: String = "":
	set(v):
		if v:
			soot_path = v
		else:
			soot_path = UFile.change_extension(scene_file_path, Soot.EXT_DIALOGUE)

func _ready() -> void:
	if not Engine.is_editor_hint():
		State.changed.connect(_property_changed)

func has_soot() -> bool:
	return UFile.file_exists_in_dir("res://dialogue", "%s.%s" % [id, Soot.EXT_DIALOGUE])

func get_soot_path() -> String:
	return UFile.get_file_in_dir("res://dialogue", "%s.%s" % [id, Soot.EXT_DIALOGUE])

func _start(loaded: bool):
	var fi := Soot.join_path([id, "scene_init"])
	if Dialogue.has_flow(fi):
		Dialogue.execute(fi)
	
	if not loaded:
		var fs := Soot.join_path([id, "scene_started"])
		if Dialogue.is_active():
			Dialogue.ended.connect(Dialogue.goto.bind(fs), CONNECT_ONESHOT)
		else:
			Dialogue.goto(fs)

func _property_changed(property: String):
	var fs := Soot.join_path([id, "CHANGED_%s" % property])
	if Dialogue.has_flow(fs):
		Dialogue.execute(fs)

func _get_tool_buttons():
	if has_soot():
		var soot_path := get_soot_path()
		return [{
			text="Edit %s.%s" % [id, Soot.EXT_DIALOGUE],
			call="@SELECT_AND_EDIT;%s" % soot_path,
			hint="Edit %s." % soot_path
		}]
	else:
		var soot_path := "res://dialogue/%s.%s" % [id, Soot.EXT_DIALOGUE]
		var soot_data := "=== START\n\tHello world.\t\nStarted %s." % id.capitalize()
		return [{
			text="Create %s.%s" % [id, Soot.EXT_DIALOGUE],
			call="@CREATE_AND_EDIT;%s;%s" % [soot_path, soot_data],
			hint="Create %s." % soot_path}]
