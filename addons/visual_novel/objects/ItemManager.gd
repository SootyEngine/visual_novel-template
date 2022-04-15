@tool
extends DataManager
class_name ItemManager
func get_class():
	return "ItemManager"

func _get_data_class() -> String:
	return "Item"
