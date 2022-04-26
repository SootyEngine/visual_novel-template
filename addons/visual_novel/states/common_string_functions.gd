@tool
extends RefCounted

#func stutter(x: String) -> String:
#	var parts := x.split(" ")
#	for i in len(parts):
#		if len(parts[i]) > 2:
#			parts[i] = parts[i].substr(0, 1 if randf()>.5 else 2) + "-" + parts[i].to_lower()
#	return " ".join(parts)

#func commas(x: String) -> String:
#	return UString.commas(UObject.get_operator_value(x))
#
#func humanize(x: String) -> String:
#	return UString.humanize(UObject.get_operator_value(x))
#
#func plural(x: String, one: String = "%s", more: String = "%s's", none: String = "%s's") -> String:
#	return UString.plural(UObject.get_operator_value(x), one, more, none)
#
#func ordinal(x: String) -> String:
#	return UString.ordinal(UObject.get_operator_value(x))
#
#func capitalize(x: String) -> String:
#	return str(x).capitalize()
#
#func lowercase(x: String) -> String:
#	return str(x).to_lower()
#
#func uppercase(x: String) -> String:
#	return str(x).to_upper()

# Cache the pick function so it doesn't give the same option too often.
# Still random, just not as boring.
#var _pick_cache := {}
#func pick(x):
#	# if a dictionary? treat as weighted dict
#	if x is Dictionary:
#		return URand.pick_weighted(x)
#
#	# cache a duplicate to be randomly picked from
#	if not x in _pick_cache:
#		_pick_cache[x] = x.duplicate()
#		_pick_cache[x].shuffle()
#
#	var got = _pick_cache[x].pop_back()
#
#	if len(_pick_cache[x]) == 0:
#		_pick_cache[x] = x.duplicate()
#		_pick_cache[x].shuffle()
#
#	return got


#
