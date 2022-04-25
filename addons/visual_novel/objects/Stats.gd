@tool
extends Data
class_name Stats
func get_class() -> String:
	return "Stats"

var base := {}
var current := {}

func get_display_state() -> Array:
	var out := []
	for stat_id in base:
		out.append({
			id=stat_id,
			stat=Stat.from_id(stat_id),
			base=base[stat_id],
			current=current[stat_id]
		})
	return out

func _get(property: StringName):
	var stat_id: String = str(property)
	if stat_id in current:
		return current[stat_id]
	else:
		return 0

func _set(property: StringName, value) -> bool:
	var stat_id: String = str(property)
	var stat: Stat = Stat.from_id(stat_id)
	if stat:
		if value is int:
			base[stat_id] = value
			_recalculate(stat_id)
		else:
			push_error("Stats like '%s' must be integers." % [stat_id])
		return true
	else:
		return false

func recalculate():
	for stat_id in base:
		_recalculate(stat_id)

func _recalculate(stat_id: String):
	if stat_id in base:
		var old_value: int = current.get(stat_id, 0)
		var new_value: int = base[stat_id]
		# TODO: calculate based on inventory and traits
		current[stat_id] = new_value
		if old_value != new_value:
			signal_changed()
	else:
		push_error("No stat '%s' to recalculate." % stat_id)

func _get_state():
	return base

func _set_state(state: Dictionary):
	base = state

func _patch_manually_deferred(stat_id: String, value: Variant, sources: Array):
	value = DataParser.patch_to_var(value, sources)
	_set(stat_id, value)
