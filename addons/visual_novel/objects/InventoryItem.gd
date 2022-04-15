extends PatchableData
class_name InventoryItem, "res://addons/visual_novel/icons/item.png"

var id := "" # item type
var sum := 0 # total

func _init(type: String, total := 1, kwargs := {}) -> void:
	id = type
	sum = total
	super._init(kwargs)

func get_item() -> Item:
	var item_manager: ItemManager = State.get_first(ItemManager)
	return item_manager.find(id)

#func _to_string() -> String:
#	if data:
#		var out := []
#		for k in data:
#			out.append("%s: %s" % [k, data[k]])
#		return "InventoryItem(%s x%s {%s})" % [id, sum, ", ".join(out)]
#	else:
#		return "InventoryItem(%s x%s)" % [id, sum]
