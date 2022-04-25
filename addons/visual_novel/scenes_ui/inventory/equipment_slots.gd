extends Node

signal item_selected(item: InventoryItem)

func _ready():
	Sooty.dialogue.started.connect(_dialogue_started)
	Sooty.dialogue.ended.connect(_dialogue_ended)

func _dialogue_started():
	for child in get_children():
		child.disabled = true

func _dialogue_ended():
	for child in get_children():
		child.disabled = false

func _on_inventory_changed(inventory) -> void:
	UNode.remove_children(self)
	
	var inv: Inventory = Sooty.state.characters.mary.inventory
	for item in inv.worn.values():
		var btn: Button = load("res://addons/visual_novel/scenes_ui/inventory/prefabs/inventory_slot.tscn").instantiate()
		btn.set_item.call_deferred(item)
		btn.pressed.connect(_pressed.bind(item))
		add_child(btn)

func _pressed(item: InventoryItem):
	item_selected.emit(item)
