@tool
extends OSApp

@export var _texture: NodePath
@onready var texture: TextureRect = get_node(_texture)

func get_app_name() -> String:
	return "Images"

func set_data(data: Variant):
	get_node(_texture).set_texture(load(data))
