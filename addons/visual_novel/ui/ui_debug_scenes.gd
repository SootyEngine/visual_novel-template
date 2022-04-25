extends Node

func _ready() -> void:
	Sooty.mods.loaded.connect(_redraw)

func _redraw():
	var text := []
	var meta := {}
	var scenes = Sooty.scenes.scenes.keys()
	scenes.sort()
	
	for scene in scenes:
		text.append("[meta %s]%s[]" % [scene, scene])
		meta[scene] = _goto_scene.bind(scene)
	var rt: RichTextLabel = $RichTextLabel
	rt.set_bbcode("\n".join(text))
	rt._meta = meta

func _goto_scene(scene: String):
	Sooty.dialogue.end()
	Sooty.scenes.change(scene)
