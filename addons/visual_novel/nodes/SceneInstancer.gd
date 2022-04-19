extends Node
# Creates a scene as a child.
# Updates when mods are loaded so a mod can replace it.

@export var scene_id := ""

func _ready() -> void:
	ModManager.loaded.connect(_recreate)

func _recreate():
	UNode.remove_children(self)
	# check if user has a replacement
	if File.new().file_exists("res://%s.tscn" % scene_id):
		var node: Node = load("res://%s.tscn" % scene_id).instantiate()
		add_child(node)
	# otherwise use the built in dummy
	elif SceneManager.has(scene_id):
		SceneManager.create(scene_id, self)
	else:
		push_error("No scene '%s'." % scene_id)
