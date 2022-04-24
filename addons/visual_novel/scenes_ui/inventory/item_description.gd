extends Node

signal item_action(action: String)

@export var _label: NodePath
@onready var label: RichTextLabel2 = get_node(_label)
@export var _button_container: NodePath
@onready var button_container: Node = get_node(_button_container)

func _pressed(id: String):
	item_action.emit(id)

func _on_items_item_selected(slot: InventoryItem) -> void:
	_show_info(slot)

func _on_worn_item_selected(slot: InventoryItem) -> void:
	_show_info(slot)

func _show_info(slot: InventoryItem):
	UNode.remove_children(button_container)
	
	if slot:
		var item := slot.get_item()
		var text := "[125;b;light_green]%s[]\n%s" % [item.name, item.desc]
		label.set_bbcode(text)
		
		for a in owner.get_item_actions():
			var btn := Button.new()
			button_container.add_child(btn)
			btn.text = a.text
			btn.pressed.connect(a.call)
		
	else:
		label.set_bbcode("")

