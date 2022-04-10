extends Node

var flow_history := []
var flow_visited := {}
var choice_history := {}
var caption_at := "bottom"
var caption_auto_clear := true
var time := DateTime.new({weekday="sat"})

var _MAIN_flow_ended = Soot.join_path(["MAIN", "flow_ended"])
var _MAIN_started = Soot.join_path(["MAIN", "started"])
var _MAIN_dialogue_ended = Soot.join_path(["MAIN", "dialogue_ended"])

func _ready() -> void:
	Global.started.connect(_game_started)
	Dialogue.started.connect(_dialogue_started)
	Dialogue.ended.connect(_dialogue_ended)
	Dialogue.flow_started.connect(_flow_started)
	Dialogue.flow_ended.connect(_flow_ended)
	Dialogue.selected.connect(_selected)

func _game_started():
	if Dialogue.has_flow(_MAIN_started):
		Dialogue.goto(_MAIN_started)
	else:
		push_error("There is no '%s' flow." % _MAIN_started)

func _selected(id: String):
	UDict.tick(choice_history, id)
	print("Selected ", id, choice_history)

func _dialogue_started():
	flow_history.clear()

func _dialogue_ended():
	var dialogue_ended := _MAIN_dialogue_ended
	if len(flow_history) and flow_history[-1] != _MAIN_dialogue_ended and Dialogue.has_flow(_MAIN_dialogue_ended):
		Dialogue.stack(_MAIN_dialogue_ended)

func _flow_started(flow: String):
	flow_history.append(flow)

func _flow_ended(flow: String):
	# tick number of times visited
	UDict.tick(flow_visited, flow)
	# goto the ending node
	if len(flow_history) and not flow_history[-1] in [_MAIN_dialogue_ended, _MAIN_flow_ended] and Dialogue.has_flow(_MAIN_flow_ended):
		Dialogue.stack(_MAIN_flow_ended)

func caption(kwargs: Dictionary):
	if "at" in kwargs:
		State._set("caption_at", kwargs.at)
	if "clear" in kwargs:
		State._set("caption_auto_clear", kwargs.clear)

func stutter(x):
	var parts := str(x).split(" ")
	for i in len(parts):
		if len(parts[i]) > 2:
			parts[i] = parts[i].substr(0, 1 if randf()>.5 else 2) + "-" + parts[i].to_lower()
	return " ".join(parts)

func commas(x: Variant):
	return UString.commas(UObject.get_operator_value(x))

func humanize(x: Variant):
	return UString.humanize(UObject.get_operator_value(x))

func plural(x: Variant, one := "%s", more := "%s's", none := "%s's"):
	return UString.plural(UObject.get_operator_value(x), one, more, none)

func ordinal(x: Variant):
	return UString.ordinal(UObject.get_operator_value(x))

func capitalize(x: Variant):
	return str(x).capitalize()

func lowercase(x: Variant):
	return str(x).to_lower()

func uppercase(x: Variant):
	return str(x).to_upper()

# Cache the pick function so it doesn't give the same option too often.
# Still random, just not as boring.
var _pick_cache := {}
func pick(x: Variant):
	# if a dictionary? treat as weighted dict
	if x is Dictionary:
		return URand.pick_weighted(x)
	
	# cache a duplicate to be randomly picked from
	if not x in _pick_cache:
		_pick_cache[x] = x.duplicate()
		_pick_cache[x].shuffle()
	
	var got = _pick_cache[x].pop_back()
	
	if len(_pick_cache[x]) == 0:
		_pick_cache[x] = x.duplicate()
		_pick_cache[x].shuffle()
	
	return got

func test(s: Variant, ontrue := "yes", onfalse := "no"):
	return ontrue if s else onfalse
