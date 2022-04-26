@tool
extends Data
class_name Trait
func get_class() -> String:
	return "Trait"
func _get_database_id():
	return "Trait"

var name: String = ""
var desc: String = ""

func get_value(value: Variant) -> Variant:
	return value

func is_value_allowed(value: Variant) -> bool:
	return true

static func from_id(id: String) -> Trait:
	return Sooty.databases.get_data(Trait, id)

func value_to_string(value: Variant) -> String:
	return str(value)
