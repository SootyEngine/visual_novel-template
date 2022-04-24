extends Node

@onready var icon := $icon
@onready var quantity := $quantity
@onready var id := $id

var current: InventoryItem

func set_item(item: InventoryItem):
	current = item
	
	icon.visible = false
	icon.texture = null
	quantity.visible = false
	quantity.text = ""
	id.visible = false
	id.text = ""
	
	if item:
		icon.visible = true
		icon.texture = item.get_item().get_icon()
		
		# debug: show id if no icon exists
		if not item.get_item().has_icon():
			id.text = item.get_item().get_id().replace("_", "\n")
			id.visible = true
		
		if item.sum > 1:
			quantity.visible = true
			quantity.text = UString.commas(item.sum)
