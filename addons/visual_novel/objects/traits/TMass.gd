@tool
extends Trait
class_name TMass

func is_value_allowed(value: Variant) -> bool:
	return typeof(value) in [TYPE_STRING, TYPE_INT]

func get_value(value: Variant) -> Variant:
	# store data as inches
	return Unit.mass(value, Unit.Mass.Gram)

func value_to_string(value: Variant) -> String:
	# convert to `0 lb` format.
	return "%s lb" % Unit.mass(value, Unit.Length.Pound, Unit.Mass.Gram)
