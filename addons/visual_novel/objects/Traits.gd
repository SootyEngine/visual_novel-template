@tool
extends Data
class_name Traits
func get_class() -> String:
	return "Traits"

signal gained(ttrait: Trait, value: Variant)
signal lost(ttrait: Trait, value: Variant)

var traits := {}

func enable(ttrait: Trait, value: Variant = true):
	_set_trait(ttrait, value)

func disable(ttrait: Trait):
	_set_trait(ttrait, null)

func _get(property: StringName):
	var trait_id: String = str(property)
	return traits.get(trait_id, false)

func _set(property: StringName, value) -> bool:
	var trait_id: String = str(property)
	var ttrait: Trait = Trait.from_id(trait_id)
	if ttrait:
		_set_trait(ttrait, value)
		return true
	return false

func _set_trait(ttrait: Trait, value: Variant):
	var trait_id := ttrait.get_id()
	
	# lost trait
	if value == null:
		if trait_id in traits:
			lost.emit(ttrait, traits[trait_id])
			traits.erase(trait_id)
			signal_changed()
	
	# gain trait
	elif ttrait.is_value_allowed(value):
		value = ttrait.get_value(value)
		
		if not trait_id in traits:
			gained.emit(ttrait, value)
		
		traits[trait_id] = value
		signal_changed()
	
	else:
		push_error("Trait '%s' can't be '%s'." % [trait_id, value])

func _get_state():
	return traits

func _set_state(state: Dictionary):
	traits = state

func _patch_manually_deferred(trait_id: String, value: Variant, sources: Array):
	value = DataParser.patch_to_var(value, sources)
	_set(trait_id, value)
