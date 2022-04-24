@tool
extends EditorPlugin

const H_MD = preload("res://addons/common_file_highlighters/highlight_md.gd")
const H_CFG = preload("res://addons/common_file_highlighters/highlight_cfg.gd")
const H_JSON = preload("res://addons/common_file_highlighters/highlight_json.gd")
var script_editor: ScriptEditor = get_editor_interface().get_script_editor()
var highlighters := {
	"md": H_MD.new(),
	"cfg": H_CFG.new(),
	"json": H_JSON.new()
}

func _enter_tree() -> void:
	# add extensions to the `Edit > Syntax Highlighter` drop down
	for extension in highlighters.keys():
		script_editor.register_syntax_highlighter(highlighters[extension])
	
	# add extensions to the file search
	var sof := "editor/script/search_in_file_extensions"
	var extensions: PackedStringArray = ProjectSettings.get_setting(sof)
	var changed := false
	for extension in highlighters.keys():
		if not extension in extensions:
			changed = true
			extensions.append(extension)
	if changed:
		ProjectSettings.set_setting(sof, extensions)
	
	# signal for auto adding highlighters based on file type
	# once a file is opened, a highlighter is auto assigned
	script_editor.editor_script_changed.connect(_editor_script_changed)

func _exit_tree() -> void:
	for extension in highlighters.keys():
		script_editor.unregister_syntax_highlighter(highlighters[extension])

func _editor_script_changed(s):
	# auto add highlighters
	for e in script_editor.get_open_script_editors():
		if e.has_meta("_edit_res_path") and not e.has_meta("_common_file_highlighter"):
			# set a flag so we don't constantly apply the highlighters.
			e.set_meta("_common_file_highlighter", true)
			
			var se: ScriptEditorBase = e
			var c: CodeEdit = se.get_base_editor()
			var resource_path: String = se.get_meta("_edit_res_path")
			var extension: String = resource_path.get_extension()
			if extension in highlighters:
				c.syntax_highlighter = highlighters[extension]
