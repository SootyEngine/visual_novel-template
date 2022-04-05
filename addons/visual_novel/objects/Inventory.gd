extends BaseDataClass
class_name Inventory

func get_class() -> String:
	return "Inventory"

signal gained(type: Item, quantity: int)
signal lost(type: Item, quantity: int)

var _character: Character
var items := []

func _added(parent: BaseDataClass):
	_character = parent

func _patch(key: String, type: String, patch: Variant, sources: Array):
#	match key:
#		"items":
		patch = UObject.patch_to_vars(patch)
		gain(key, patch)
#		match typeof(patch):
#			TYPE_ARRAY:
#				for item in patch:
#					gain(item)
#			TYPE_DICTIONARY:
#				for k in patch:
#					gain(k, patch[k])
#			_:
#				push_error("Not implemented %s %s." % [key, patch])

func _get(property: StringName):
	if has(str(property)):
		return count(str(property))

func has(type: String, quantity := 1) -> bool:
	var q := 0
	for i in len(items):
		if items[i].type == type:
			q += items[i].total
		if q >= quantity:
			return true
	return false

func count(type: String) -> int:
	var out := 0
	for i in len(items):
		if items[i].type == type:
			out += items[i].total
	return out

func gain(type: String, quantity := 1, _meta := {}):
	var all_items: Items = State.items
	var info: Item = all_items.find(type, "gain")
	if not info:
		return
	
	# try to append to previous slots
	var q := quantity
	for item in items:
		if item.type == type and item.total < info.slot_max:
			var amount := mini(info.slot_max, q)
			item.total += amount
			q -= amount
			if q <= 0:
				break
	
	# create new slots for leftovers
	for i in ceil(q / float(info.slot_max)):
		var amount := mini(info.slot_max, q)
		q -= amount
		items.append({ type=type, total=amount })
	
	var dif := quantity - q
	gained.emit(info, dif)

func lose(type: String, quantity := 1, _meta := {}):
	var all_items: Items = State.items
	var info: Item = all_items.find(type, "lose")
	if not info:
		return
	
	var q := quantity
	for i in range(len(items)-1, -1, -1):
		var item = items[i]
		if item.type == type:
			var amount := mini(item.total, q)
			item.total -= amount
			q -= amount
			if q <= 0:
				items.remove_at(i)
				break
	
	var dif := quantity - q
	lost.emit(info, dif)
