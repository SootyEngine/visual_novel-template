@tool
extends RichTextAnimation

@export var disabled := false

func _ready() -> void:
	visible = false
	
	await get_tree().process_frame
	Sooty.actions.connect_methods([caption_label, advance_caption])
	
	VisualNovel.caption_started.connect(_caption_started)
	VisualNovel.caption_ended.connect(_caption_ended)
	VisualNovel.option_selected.connect(_option_selected)
	clear()

func _caption_started(caption: String):
	if disabled:
		return
	
	visible = true
	VisualNovel.wait(self)
	set_bbcode(caption)
	
	# skip text animation?
	if Sooty.config.skip_text_animation:
		advance()

func _caption_ended():
	#TODO: check if same as current, then we don't need to go away
	visible = false
	clear()

func advance_caption():
	if can_advance():
		advance()
	else:
		VisualNovel.unwait(self)
		visible = false

func _option_selected():
	VisualNovel.unwait(self)

func caption_label(id: String, kwargs := {}):
	disabled = id != name
