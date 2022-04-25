extends Node

func _ready() -> void:
	Sooty.mods.loaded.connect(_redraw)

func _redraw():
	var text := []
	var meta := {}
	
	text.append("[b]MUSIC[]")
	text.append("[meta stop_music]Stop[]")
	meta["stop_music"] = Sooty.music.stop()
	
	for id in Sooty.music._files:
		text.append("[meta music:%s]\t%s[]" % [id, id])
		meta["music:"+id] = Sooty.music.play_music.bind(id)
		
	text.append("[b]SFX[]")
	for id in Sooty.sound._files:
		text.append("[meta sfx:%s]\t%s[]" % [id, id])
		meta["sfx:"+id] = Sooty.sound.play_sound.bind(id)
	
	$RichTextLabel.set_bbcode("\n".join(text))
	$RichTextLabel._meta = meta
