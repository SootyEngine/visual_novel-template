extends Node

signal waiting_changed()
signal caption_started()
signal speaker_started()
signal caption_ended()
signal speaker_ended()
signal option_selected()

# flow state
var history := [] # flow history
var visited := {} # flow visit counts
var choices := {} # choice counts

# time
var start_time: int = 0 # seconds from DateTime
var play_time: int = 0 # seconds from DateTime
var _last_play_time: int = 0 # seconds

# if state changes during dialogue, trigger an autosave
var _state_changed := false

# current line info
var _caption := ""
var _speaker := ""
var _option := ""
var _current_line: Dictionary
var _waiting_for := []

func _ready() -> void:
	if not Engine.is_editor_hint():
		Sooty.started.connect(_on_game_started)
		Sooty.actions.connect_methods([goto_scene])
		
		Sooty.dialogue.started.connect(_on_dialogue_started)
		Sooty.dialogue.ended.connect(_on_dialogue_ended)
		Sooty.dialogue.flow_started.connect(_on_flow_started)
		Sooty.dialogue.flow_ended.connect(_on_flow_ended)
		Sooty.dialogue.selected.connect(_option_selected)
		Sooty.dialogue.caption.connect(_on_caption)
		
		Sooty.state._changed.connect(_on_state_changed)
		Sooty.persistent._changed.connect(_on_state_changed)
		
		Sooty.saver._get_state.connect(_save_state)
		Sooty.saver._set_state.connect(_load_state)
		
		Sooty.scenes.changed.connect(_on_scene_changed)
		
		start_new_game.call_deferred()

func start_new_game():
	Sooty.mods.load_mods.call_deferred()
	await Sooty.mods.loaded
	Sooty.dialogue.start("_start")

enum Transition { FADE_OUT, INSTANT }
func goto_scene(id: String, transition: Transition = Transition.FADE_OUT, kwargs := {}):
	if Sooty.scenes.find(id):
		wait(self)
		Fader.create(
			Sooty.scenes.change.bind(Sooty.scenes.scenes[id]),
			unwait.bind(self))
	else:
		# Scene.find will push_error with more useful data.
		pass

func get_current_line() -> Dictionary:
	return _current_line

func _on_scene_changed():
	if Sooty.scenes.is_current_a_scene():
		# execute the scene_init
		Sooty.dialogue.try_execute(Flow.get_scene_path("_init"))
		
		# if dialogue is already running, add this to the end of the current flow
		Sooty.dialogue.try_start(Flow.get_scene_path("_started"))

func _save_state(state: Dictionary):
	# update total time played
	var current_seconds := DateTime.create_from_current().get_total_seconds()
	play_time += (current_seconds - _last_play_time)
	_last_play_time = play_time
	state["VN"] = UObject.get_state(self)

func _load_state(state: Dictionary):
	_last_play_time = DateTime.create_from_current().get_total_seconds()

func _on_state_changed(property: String):
	_state_changed = true
	Sooty.dialogue.try_start(Flow.get_scene_path("_changed/%s" % [property]))

# an option was selected
# tell ui nodes to react
func _option_selected(id: String):
	_option = id
	option_selected.emit()
	UDict.tick(choices, id)

func is_showing_caption() -> bool:
	return true if _current_line else false

func _on_caption(text: String, line := {}):
	# replace list patterns
	text = Sooty.dialogue.replace_list_text(line.M.id, text)
	
	var info := DialogueTools.str_to_dialogue(text)
	var has_speaker := true if _speaker else false
	var had_caption := true if _caption else false
	
	_current_line = line
	_speaker = str_to_speaker(info.from)
	_caption = info.text
	
	# signal the next speaker, since nodes might not want to hide if it's the same speaker
	if had_caption:
		caption_ended.emit()
	if has_speaker:
		speaker_ended.emit()
	
	caption_started.emit(_caption)
	
	if _speaker:
		speaker_started.emit(_speaker)

func _on_game_started():
	if Sooty.dialogue.try_start("_start"):
		play_time = 0
		_last_play_time = DateTime.create_from_current().get_total_seconds()
	else:
		push_error("There is no '%s' flow." % "_start")

func _on_flow_started(flow: String):
	history.append(flow)

func _on_flow_ended(flow: String):
	# tick number of times visited
	UDict.tick(visited, flow)
	# goto the ending node
	if len(history) and not history[-1] in ["_dialogue_ended", "_flow_ended"]:
		Sooty.dialogue.try_start("_flow_ended")

func _process(delta: float) -> void:
	if not Engine.is_editor_hint():
		if not is_waiting() and Sooty.dialogue.is_active():
			Sooty.dialogue.step()

func _input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		set_process_input(false)
		return
	
	for action in InputMap.get_actions():
		if Input.is_action_just_pressed(action):
			print("ACTION ", action)
	
	if is_showing_caption():
		if event.is_action_pressed("advance"):
			if is_waiting():
				Sooty.actions.do("@advance_caption")
			else:
				Sooty.actions.do("@hide_caption")
				unwait(self)
				
		# run input for captions
		for node in _waiting_for:
			if node.has_method("_vn_input"):
				node._vn_input(event)

func _on_dialogue_started():
	history.clear()
	_state_changed = false

func _on_dialogue_ended():
	_current_line = {}
	
	if _speaker:
		_speaker = ""
		speaker_ended.emit()
	
	if _caption:
		_caption = ""
		caption_ended.emit()
	
	# auto save if state changed
	if _state_changed:
		_state_changed = false
		print("Autosaving")
		Sooty.saver.save_slot("auto")
	
	if len(history) and history[-1] != "_dialogue_ended":
		Sooty.dialogue.try_start("_dialogue_ended")

# causes the dialogue to pause
func wait(node: Node):
	if not node in _waiting_for:
		Sooty.dialogue.break_step()
		_waiting_for.append(node)
		waiting_changed.emit()

# unpauses dialogue, when empty
func unwait(node: Node):
	if node in _waiting_for:
		_waiting_for.erase(node)
		waiting_changed.emit()

func is_waiting() -> bool:
	return len(_waiting_for) > 0

func _get_method_info(method: String):
	match method:
		"goto_scene":
			return {
				args={
					path={
						# auto complete list of scenes
						id=Sooty.scenes.get_all_ids,
						icon=preload("res://addons/sooty_engine/icons/scene.png"),
					}
				}
			}

static func get_speaker(from: String) -> String:
	var db: Database = Sooty.databases.get_database(Character)
	var out = from
	if db and db.has(from):
		out = db.get(from)
	elif Sooty.state._has(from):
		out = Sooty.state._get(from)
	return UString.get_string(out, "speaker_name")

static func str_to_speaker(from: String) -> String:
	if from:
		# if wrapped, use as is.
		if UString.is_wrapped(from, '"'):
			from = UString.unwrap(from, '"')
		
		# if multiple names, join them together.
		elif " " in from:
			var names = Array(from.split(" "))
			for i in len(names):
				names[i] = get_speaker(names[i])
			from = names.pop_back()
			if len(names):
				from = ", ".join(names) + ", and " + from
		
		# if a state, format it's text.
		else:
			from = get_speaker(from)
	
	return from
