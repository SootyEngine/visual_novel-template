extends OSApp

@export var _contact_container: NodePath
@onready var contact_container: Control = get_node(_contact_container)
@export var contact_prefab: PackedScene

func get_app_name() -> String:
	return "Contacts"

func get_title() -> String:
	return "Contacts"

func set_data(data: Variant):
	for c in [{}, {}, {}]:
		var contact = contact_prefab.instantiate()
		contact_container.add_child(contact)
		contact.set_data(c)
		
		contact_container.add_child(HSeparator.new())
