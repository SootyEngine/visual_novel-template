@tool
extends EditorPlugin

const PRINTR := preload("res://addons/printr/printr.tscn")
var printr: Node

func _enter_tree() -> void:
	printr = PRINTR.instantiate()
	printr.pluginref = self
	printr.is_plugin = true
	
	add_control_to_bottom_panel(printr, "Printr")
	add_autoload_singleton("pri", "res://addons/printr/Printr.gd")

func _exit_tree() -> void:
	remove_control_from_bottom_panel(printr)
	remove_autoload_singleton("pri")
