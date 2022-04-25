@tool
extends Trait
class_name TLevel

var max := 1

func is_value_allowed(value: Variant) -> bool:
	return value is int
