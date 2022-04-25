@tool
extends Trait
class_name THeight

func is_value_allowed(value: Variant) -> bool:
	return typeof(value) in [TYPE_STRING, TYPE_INT]

func get_value(value: Variant) -> Variant:
	# store data as inches
	return Unit.length(value, Unit.Length.Inch)

func get_string(value: Variant, for_what := "") -> String:
	# convert to 0'0" format.
	return Unit.to_feet_and_inches(value)
