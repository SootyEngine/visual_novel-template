extends Waiter

const VERSION := "1.0"

class Debug:
	# when displaying dialogue options, do you want hidden ones to be shown?
	var show_hidden_options := false
	
	# toggle with q
	var allow_debug_menu := true

var debug := Debug.new()

func _init() -> void:
	add_to_group("@VN")

func _ready() -> void:
	await get_tree().process_frame
	Mods._add_mod("res://addons/visual_novel", true)
	Scene._goto = _goto_scene
	
	if not Engine.is_editor_hint():
		Dialogue.started.connect(_dialogue_started)
		Dialogue.ended.connect(_dialogue_ended)
		Dialogue.caption.connect(_caption)
#		Dialogue.reloaded.connect(Dialogue.unwait.bind(self))
	
	$captions/backing.visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("advance"):
		if is_waiting():
			StringAction.do_group_action("@advance_caption")
		else:
			StringAction.do_group_action("@hide_caption")
			Dialogue.unwait(self)

func _caption(text: String, line: Dictionary):
	# replace list patterns
	text = Dialogue.replace_list_text(line.M.id, text)
	
	var d := DialogueTools.str_to_dialogue(text)
#	d.text = DialogueTools.str_to_caption(d.from, d.text)
#	d.from = DialogueTools.str_to_speaker(d.from)
	
	StringAction.do_group_action_w_args("@show_caption", [
#		format_from(from),
#		format_text(from , text),
		d.from,
		d.text,
		line])

func _goto_scene(id: String, kwargs := {}):
	if Scene.find(id):
		Dialogue.wait(self)
		Fader.create(
			Scene.change.bind(Scene.scenes[id]),
			Dialogue.unwait.bind(self))
	else:
		# Scene.find will push_error with more useful data.
		pass

func version() -> String:
	return VERSION

func _dialogue_started():
	$captions/backing.visible = true

func _dialogue_ended():
	$captions/backing.visible = false



#func format_text(text: String, has_speaker: bool) -> String:
#	var out := ""
#	var part_count := 0
#	# when someone is speaking, use brakets to toggle 'predicate' mode.
#	if has_speaker:
#		var parts = UString.split_between(text, "(", ")")
#		for p in parts:
#			if not part_count == 0:
#				out += "[w=%s]" % QUOTE_DELAY
#			var whitespace = _get_whitespace_format(p)
#			if UString.is_wrapped(p, '(', ')'):
#				p = UString.unwrap(p, '(', ')').strip_edges()
#				out += whitespace % FORMAT_PREDICATE % p
#			else:
#				p = p.strip_edges()
#				p = UString.replace_between(p, '"', '"', _replace_inner_quotes)
#				out += whitespace % FORMAT_QUOTE % QUOTES % p
#			part_count += 1
#	else:
#		var parts = UString.split_between(text, "\"", "\"")
#		for p in parts:
#			if not part_count == 0:
#				out += "[w=%s]" % QUOTE_DELAY
#			var whitespace = _get_whitespace_format(p)
#			if UString.is_wrapped(p, '"'):
#				p = UString.unwrap(p, '"')
#				p = UString.replace_between(p, "'", "'", _replace_inner_quotes)
#				out += whitespace % FORMAT_QUOTE % QUOTES % p
#			else:
#				p = p.strip_edges()
#				out += whitespace % FORMAT_PREDICATE % p
#			part_count += 1
#	return out

#func _replace_inner_quotes(t: String) -> String:
#	return FORMAT_INNER_QUOTE % INNER_QUOTES % t

# get the left and right whitespace, as a format string.
#func _get_whitespace_format(s: String):
#	var l := len(s) - len(s.strip_edges(true, false))
#	var r := len(s) - len(s.strip_edges(false, true))
#	return s.substr(0, l) + "%s" + s.substr(len(s) - r)

