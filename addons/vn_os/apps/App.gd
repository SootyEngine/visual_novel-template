extends Node
class_name OSApp

var window: OSAppWindow
var file_path: String

func get_app_name() -> String:
	return "App"
	
func get_title() -> String:
	return "%s - %s" % [get_file_name(), get_app_name()]

func get_file_name() -> String:
	return file_path.rsplit("/", true, 1)[-1]
