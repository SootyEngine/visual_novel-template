@tool
extends Trait
class_name TTemperature

func is_value_allowed(value: Variant) -> bool:
	return typeof(value) in [TYPE_STRING, TYPE_INT]

func get_value(value: Variant) -> Variant:
	# store data as inches
	return Unit.temp(value, Unit.Temp.Celsius)

func value_to_string(value: Variant) -> String:
	# TODO: Check if people want it in cm instead.
	# convert to 0'0" format.
	return Unit.to_feet_and_inches(value)
