@tool
extends PatchableData
class_name Item, "res://addons/visual_novel/icons/item.png"
func get_class() -> String:
	return "Item"
func _get_database_id():
	return "Item"

var name := ""
var desc := ""
var worn_to: Array[String] = []
var slot_max := 16:
	get: return 1 if is_wearable() else slot_max

func get_icon_path() -> String:
	return "res://gfx/item_icons"

func is_wearable() -> bool:
	return len(worn_to) > 0

func get_first_slot() -> EquipmentSlot:
	return Sooty.databases.get_data(EquipmentSlot, worn_to[0])

func get_slots() -> Array:
	var out: Array = []
	var sdb: Database = Sooty.databases.get_database(EquipmentSlot)
	for slot_id in worn_to:
		out.append(sdb.get(slot_id))
	return out

static func from_id(id: String) -> Item:
	return Sooty.databases.get_data(Item, id)
