extends Node
# Creates a scene as a child.
# Updates when mods are loaded so a mod can replace it.

@export var scene_id := ""

func _ready() -> void:
	Mods.loaded.connect(_recreate)

func _recreate():
	UNode.remove_children(self)
	Scene.create(scene_id, self)
