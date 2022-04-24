@tool
extends PatchableData
class_name Item, "res://addons/visual_novel/icons/item.png"
func get_class() -> String:
	return "Item"

var name := ""
var desc := ""
var worn_to: Array[String] = []
var slot_max := 16:
	get: return 1 if is_wearable() else slot_max

func has_icon() -> bool:
	return UFile.exists("res://gfx/item_icons/%s.png" % get_id())

func get_icon() -> Texture:
	var path := "res://gfx/item_icons/%s.png" % get_id()
	if UFile.exists(path):
		return load(path)
	else:
		return load("res://icon.png")

func is_wearable() -> bool:
	return len(worn_to) > 0

func get_first_slot() -> EquipmentSlot:
	return DataManager.get_data(EquipmentSlot, worn_to[0])

func get_slots() -> Array:
	var out: Array = []
	var sdb: Database = DataManager.get_database(EquipmentSlot)
	for slot_id in worn_to:
		out.append(sdb.get(slot_id))
	return out

static func from_id(id: String) -> Item:
	return DataManager.get_data(Item, id)
