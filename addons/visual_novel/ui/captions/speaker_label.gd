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
	Sooty.actions.connect_methods(self, [speaker_label])
	
	if not Engine.is_editor_hint():
		VisualNovel.caption_started.connect(_caption_started)
		VisualNovel.caption_ended.connect(_caption_ended)
		VisualNovel.option_selected.connect(_option_selected)
		clear()

func _preparse(t: String) -> String:
	return super._preparse(head + t + tail)

func _caption_started():
	if disabled:
		return
	
	if VisualNovel.speaker:
		visible = true
		set_bbcode(VisualNovel.speaker)

func _caption_ended():
	visible = false
	clear()

func _option_selected():
	pass

func speaker_label(id: String, kwargs := {}):
	disabled = id != name
