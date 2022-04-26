@tool
extends Data
class_name Inventory, "res://addons/visual_novel/icons/inventory.png"
func _get_database_id():
	return "Inventory"

signal gained(item: Item, quantity: int)
signal lost(item: Item, quantity: int)
signal equipped(item: Item, slot: EquipmentSlot)
signal unequipped(item: Item, slot: EquipmentSlot)

var worn := {}
var items := []

func _patch_property_deferred(key: String, value: Variant):
	if key == "items":
		match typeof(value):
			TYPE_DICTIONARY:
				for item_id in value:
					var item := Item.from_id(item_id)
					if item:
						gain(item, value[item_id])
			_: push_error("Not implemented.")
	elif key == "worn":
		match typeof(value):
			TYPE_DICTIONARY:
				for item_id in value:
					var slot := EquipmentSlot.from_id(item_id)
					var item := Item.from_id(value[item_id])
					if item and slot:
						wear(item, slot)
			_: push_error("Not implemented.")
	else:
		push_error("Nothing patchable to '%s' for %s." % [key, value])

func get_at(index: int) -> InventoryItem:
	return items[index] if index >= 0 and index < len(items) else null

func has(item: Item, quantity := 1, include_equipped := true) -> bool:
	var item_id := item.get_id()
	var q := 0
	for inv_item in _all_items(include_equipped):
		if inv_item.id == item_id:
			q += inv_item.sum
		if q >= quantity:
			return true
	return false

func count(item: Item, include_equipped := true) -> int:
	var item_id := item.get_id()
	var out := 0
	for inv_item in _all_items(include_equipped):
		if inv_item.id == item_id:
			out += inv_item.sum
	return out

func gain(item: Item, quantity := 1, kwargs := {}):
	var q := quantity
	
	# try to append to previous slots
	var item_id := item.get_id()
	for slot in items:
		if slot.id == item_id and slot.sum < item.slot_max:
			var amount := mini(item.slot_max, q)
			slot.sum += amount
			q -= amount
			if q <= 0:
				break
	
	# create new slots for leftovers
	for i in ceil(q / float(item.slot_max)):
		var min := mini(item.slot_max, q)
		q -= min
		_add_slot(item, min)
	
	var dif := quantity - q
	gained.emit(item, dif)
	signal_changed()

func lose(item: Item, quantity := 1, kwargs := {}):
	var q := quantity
	var item_id := item.get_id()
	for i in range(len(items)-1, -1, -1):
		var slot: InventoryItem = items[i]
		if slot.id == item_id:
			var min := mini(slot.sum, q)
			q -= min
			slot.sum -= min
			if slot.sum <= 0:
				items.remove_at(i)
				break
	
	var dif := quantity - q
	lost.emit(item, dif)
	signal_changed()

func _find_slot(item: Item) -> InventoryItem:
	for i in len(items):
		if items[i].id == item.get_id():
			return items[i]
	return null

func _add_slot(item: Item, total: int):
	items.append(InventoryItem.new(item, total))

func _all_items(include_equipped := true) -> Array[InventoryItem]:
	if include_equipped:
		return items + worn.values()
	else:
		return items

#
# EQUIPMENT RELATED
#

# get an item equiped at the current slot (or null)
func get_equipped_at(slot: EquipmentSlot) -> InventoryItem:
	var slot_id := slot.get_id()
	for slot in worn:
		if slot == slot_id:
			return worn[slot]
	return null

# wear an item from the inventory
func wear(item: Item, slot: EquipmentSlot = null, create_if_hasnt := true) -> bool:
	var item_id := item.get_id()
	
	# item is wearable?
	if not item.is_wearable():
		push_error("Item '%s' isn't wearable." % item_id)
		return false
	
	# check if we have the item
	var inv_item := _find_slot(item)
	if not inv_item:
		if create_if_hasnt:
			# create it
			inv_item = InventoryItem.new(item)
			items.append(inv_item)
			# alert that item was gained
			gained.emit(item, 1)
		else:
			push_error("Don't have '%s' to wear." % [item_id])
			return false
	
	return wear_from(inv_item, slot)

func wear_from(inv_item: InventoryItem, slot: EquipmentSlot = null) -> bool:
	var item: Item = inv_item.get_item()
	var _slot := slot
	
	# item is wearable?
	if not item.is_wearable():
		push_error("Item '%s' isn't wearable." % item.get_id())
		return false
	
	# if no explicit slot set, just use the first
	if _slot == null:
		_slot = item.get_first_slot()
	
	# bare any other slots
	# and bare whatever this one is
	var slot_id := _slot.get_id()
	for b in [slot_id] + _slot.bare:
		_bare_slot(b)
	
	# remove it from the inventory
	items.erase(inv_item)
	inv_item.worn_to = slot_id
	# add it to worn
	worn[slot_id] = inv_item
	equipped.emit(item, _slot)
	signal_changed()
	return true

func bare(item: Item):
	var item_id := item.get_id()
	for slot_id in worn.keys():
		if worn[slot_id].type == item_id:
			_bare_slot(slot_id)
			break

func bare_at(inv_item: InventoryItem):
	if inv_item.is_worn():
		_bare_slot(inv_item.worn_to)

func bare_slot(slot: EquipmentSlot):
	_bare_slot(slot.get_id())

func _bare_slot(slot_id: String):
	if slot_id in worn:
		var inv_item: InventoryItem = worn[slot_id]
		inv_item.worn_to = ""
		# add the item back to the inventory
		items.append(inv_item)
		
		# remove equipment slot
		worn.erase(slot_id)
		
		# signal that item was unequipped
		var slot: EquipmentSlot = Sooty.databases.get_data(EquipmentSlot, slot_id)
		unequipped.emit(inv_item.get_item(), slot)
		signal_changed()
