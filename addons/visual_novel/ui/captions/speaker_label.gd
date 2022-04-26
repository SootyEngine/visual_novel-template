@tool
extends RichTextLabel2

@export var disabled := false

@export var head := "[dima;lb;]":
	set(x):
		head = x
		_redraw()
		
@export var tail := "[dima;rb;]":
	set(x):
		tail = x
		_redraw()

func _ready() -> void:
	visible = false
	
	await get_tree().process_frame
	Sooty.actions.connect_methods([speaker_label])
	VisualNovel.speaker_started.connect(_speaker_started)
	VisualNovel.speaker_ended.connect(_speaker_ended)
	clear()

func _preparse(t: String) -> String:
	return super._preparse(head + t + tail)

func _speaker_started(speaker: String):
	if disabled:
		return
	
	visible = true
	set_bbcode(speaker)

func _speaker_ended():
	visible = false
	clear()

func speaker_label(id: String, kwargs := {}):
	disabled = id != name
