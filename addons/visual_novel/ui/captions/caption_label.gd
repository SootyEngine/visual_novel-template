@tool
extends RichTextAnimation

@export var disabled := false
@export var active := false

func _init() -> void:
	add_to_group("@.caption_label")

func _ready() -> void:
	if not Engine.is_editor_hint():
		VisualNovel.caption_started.connect(_caption_started)
		VisualNovel.caption_ended.connect(_caption_ended)
		VisualNovel.option_selected.connect(_option_selected)
		clear()

func _caption_started():
	if disabled:
		return
	
	active = true
	VisualNovel.wait(self)
	set_bbcode(VisualNovel.caption)

func _caption_ended():
	#TODO: check if same as current, then we don't need to go away
	active = false
	clear()

func _vn_input(event: InputEvent) -> void:
	if not active:
		return
	
	if event.is_action_pressed("advance"):
		if can_advance():
			advance()
		else:
			VisualNovel.unwait(self)
			active = false

func _option_selected():
	VisualNovel.unwait(self)

func caption_label(id: String, kwargs := {}):
	disabled = id != name
