@tool
extends Data
class_name EquipmentSlot
func get_class() -> String:
	return "EquipmentSlot"
func _get_database_id():
	return "EquipmentSlot"

var name := ""
var desc := ""
var bare: Array[String] = [] # slots to bear when equipped

var block_items: Array[String]= [] # items that can't be worn even if wearable to this slot
var allow_items: Array[String]= [] # items that can be worn even if not wearable to this slot
var block_types: Array[String]= []
var allow_types: Array[String]= []

func can_equip(item: Item) -> bool:
	var item_id := item.get_id()
	
	if item_id in block_items:
		return false
	
	if item_id in allow_items:
		return true
	
	return false

static func from_id(id: String) -> EquipmentSlot:
	return Sooty.databases.get_data(EquipmentSlot, id)
