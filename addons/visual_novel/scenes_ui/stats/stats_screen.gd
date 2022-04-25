extends Node

const STAT_PREFAB := preload("res://addons/visual_novel/scenes_ui/stats/prefabs/stat.tscn")

@export var _container: NodePath
@onready var container: Node = get_node(_container)

func _ready() -> void:
	populate(Sooty.state.characters.mary.stats)

func populate(stats: Stats):
	UNode.remove_children(container)
	
	for stat in stats.get_display_state():
		var n: Node = STAT_PREFAB.instantiate()
		container.add_child(n)
		n.setup(stat)
