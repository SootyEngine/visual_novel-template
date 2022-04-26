@tool
extends Data
class_name Stat
func get_class() -> String:
	return "Stat"
func _get_database_id():
	return "Stat"

var name: String = ""
var desc: String = ""
var max: int = 1

static func from_id(id: String) -> Stat:
	return Sooty.databases.get_data(Stat, id)

func value_to_string(value: Variant) -> String:
	return str(value)
