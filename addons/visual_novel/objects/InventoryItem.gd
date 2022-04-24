extends PatchableData
class_name InventoryItem, "res://addons/visual_novel/icons/item.png"

var id := "" # item type
var sum := 0 # total
var worn_to := ""
var data := {} # only used for some objects

func _init(item: Item, total := 1, kwargs := {}) -> void:
	id = item.get_id()
	sum = total
	super._init(kwargs)

func is_worn() -> bool:
	return worn_to != ""

func get_item() -> Item:
	return DataManager.get_data(Item, id)

func _get_state() -> Dictionary:
	var out := {id=id, sum=sum}
	if worn_to:
		out.worn = worn_to
	if len(data):
		out.data = data
	return out

func _set_state(state: Dictionary):
	id = state.id
	sum = state.sum
	worn_to = state.get("worn", "")
	data = state.get("data", {})
