extends Node

signal changed(inventory: Inventory)
@export var _inventory: String = "p"
var inventory: Inventory 
var selected_item: InventoryItem

func _ready():
	$close.pressed.connect(_close)
	
#	await ModManager.loaded
	inventory = State.characters[_inventory].inventory
	inventory.changed.connect(_update)
	
	_update()

func _close():
	queue_free()

func get_item_actions() -> Array:
	var out := []
	var item := selected_item.get_item()
	
	if selected_item.is_worn():
		out.append({text="Unequip", call=_unequip})
		
		var p := "/_inventory_item_worn/%s" % item.get_id()
		if Dialogue.exists(p):
			out.append({text="Use", call=Dialogue.start.bind(p)})
	else:
		if item.is_wearable():
			out.append({text="Equip", call=_equip})
	
	var p := "/_inventory_item/%s" % item.get_id()
	if Dialogue.exists(p):
		out.append({text="Use", call=Dialogue.start.bind(p)})
	
	return out

func _unequip():
	if selected_item:
		inventory.bare_at(selected_item)

func _equip():
	if selected_item:
		inventory.wear_from(selected_item)


func _update():
	changed.emit(inventory)

func _on_description_item_action(action: String) -> void:
	prints(action, selected_item)
	if selected_item:
		match action:
			"use":
				var goto := "/_inventory_item/%s" % selected_item.get_item().get_id()
				if Dialogue.can_goto(goto):
					Dialogue.start(goto)
			
			"equip":
				inventory.wear_from(selected_item)

func _on_items_item_selected(item: InventoryItem) -> void:
	selected_item = item

func _on_worn_item_selected(item: InventoryItem) -> void:
	selected_item = item
