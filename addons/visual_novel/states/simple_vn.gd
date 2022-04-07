extends Node

var flow_history := []
var flow_visited := {}
var caption_at := "bottom"
var caption_auto_clear := true
var time := DateTime.new({weekday="sat"})

func _ready() -> void:
	DialogueStack.started.connect(_dialogue_started)
	DialogueStack.flow_started.connect(_flow_started)
	DialogueStack.flow_ended.connect(_flow_ended)

func _dialogue_started():
	flow_history.clear()

func _flow_started(flow: String):
	flow_history.append(flow)

func _flow_ended(flow: String):
	# tick number of times visited
	UDict.tick(flow_visited, flow)
	# goto the ending node
	if len(flow_history) and flow_history[-1] != Soot.M_FLOW_END and Dialogues.has_flow(Soot.M_FLOW_END):
		DialogueStack.goto(Soot.M_FLOW_END)

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
