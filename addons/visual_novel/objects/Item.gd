extends BaseDataClassExtendable
class_name Item

func get_class() -> String:
	return "Item"

var name := ""
var desc := ""
var slot_max := 1:
	get: return 1 if is_wearable() else slot_max
var worn_to := []

func is_wearable() -> bool:
	return len(worn_to) > 0
