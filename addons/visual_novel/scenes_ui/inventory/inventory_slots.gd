extends Control

signal item_selected(item: InventoryItem)

func _ready():
	for i in get_child_count():
		var btn := get_child(i)
		btn.pressed.connect(_pressed.bind(i))
		btn.mouse_entered.connect(_mouse_entered.bind(i))
	
	Sooty.dialogue.started.connect(_dialogue_started)
	Sooty.dialogue.ended.connect(_dialogue_ended)

func _on_inventory_changed(inventory: Inventory) -> void:
	for i in get_child_count():
		get_child(i).set_item(inventory.get_at(i))

func _mouse_entered(slot_index: int):
	var btn := get_child(slot_index)
	if not btn.disabled:
		btn.grab_focus()

func _dialogue_started():
	for child in get_children():
		child.disabled = true

func _dialogue_ended():
	for child in get_children():
		child.disabled = false

func _pressed(slot_index: int):
	item_selected.emit(get_child(slot_index).current)

