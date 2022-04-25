@tool
extends Trait
class_name TEnum

var options := []

func is_value_allowed(value: Variant) -> bool:
	return value in options
