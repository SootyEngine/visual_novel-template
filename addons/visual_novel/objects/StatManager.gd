@tool
extends Database
class_name StatDatabase
func get_class() -> String:
	return "StatDatabase"

func _get_data_class() -> String:
	return "Stat"
