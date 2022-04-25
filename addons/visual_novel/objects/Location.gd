extends PatchableData
class_name Location, "res://addons/visual_novel/icons/location.png"
func get_class() -> String:
	return "Location"
func _get_database_id():
	return "Location"

var at := ""
var name: String = ""
var desc: String = ""
var inventory: Inventory = Inventory.new()
var traits: Dictionary = {}
var stats: Dictionary = {}
