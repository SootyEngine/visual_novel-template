@tool
extends RefCounted
class_name Unit

enum Length { Inch, Foot, Centimeter, Meter, Kilometer, Mile }
enum Mass { Gram, Pound, Ounce, Kilogram, Ton }

# TODO: Better test these numbers

const _LENGTH_FORMS := {
	"in": Length.Inch,
	"ft": Length.Foot,
	"cm": Length.Centimeter,
	"m": Length.Meter,
	"km": Length.Kilometer,
	"mi": Length.Mile
}

const _INCH := {
	Length.Inch: 1.0,
	Length.Foot: 0.0833333,
	Length.Centimeter: 2.54,
	Length.Kilometer: 2.54e-5,
	Length.Mile: 1.57828e-5,
}

const _FOOT := {
	Length.Inch: 12.0,
	Length.Foot: 1.0,
	Length.Centimeter: 30.48,
	Length.Kilometer: 0.0003048,
	Length.Mile: 0.000189394,
}

const _METER := {
#	Inch: 12.0,
#	Foot: 1.0,
#	Centimeter: 30.48,
#	Kilometer: 0.0003048,
#	Mile: 0.000189394,
}

const _KILOMETER := {
#	Inch: 12.0,
#	Foot: 1.0,
#	Centimeter: 30.48,
#	Kilometer: 0.0003048,
#	Mile: 0.000189394,
}

const _MILE := {
#	Inch: 12.0,
#	Foot: 1.0,
#	Centimeter: 30.48,
#	Kilometer: 0.0003048,
#	Mile: 0.000189394,
}

const _LENGTH_CONVERT := {
	Length.Inch: _INCH,
	Length.Foot: _FOOT,
	Length.Meter: _METER,
	Length.Kilometer: _KILOMETER,
	Length.Mile: _MILE,
}

static func length(value: Variant, to: Variant, from: Variant = null) -> float:
	if value is String:
		# form: 0'0"
		if "'" in value:
			var p = value.split("'", true, 1)
			var feet = p[0]
			var inches = "0" if not '"' in p[1] else p[1].split('"', true, 1)[0]
			value = feet.to_float() * 12.0 + inches.to_float()
			from = Length.Inch
		# form: 0 unit
		elif " " in value:
			var p = value.split(" ", true, 1)
			value = p[0].to_float()
			from = p[1]
		else:
			push_error("Can't convert length '%s'." % [value])
	
	if to is String:
		to = _from_form(_LENGTH_FORMS, from)
	
	if from == null:
		push_error("Can't convert %s to %s: Unknown unit. Leaving unconverted." % [value, Length.keys()[to]])
		return value
	
	if from is String:
		from = _from_form(_LENGTH_FORMS, from)
	
	if from == to:
		return value
	
	return value * _LENGTH_CONVERT[from][to]

static func to_feet_and_inches(inches: float) -> String:
	inches = ceil(inches)
	return "%s'%s\"" % [int(inches / 12), int(inches) % 12]

const _MASS_FORMS := {
	"oz": Mass.Ounce,
	"lb": Mass.Pound,
	"g": Mass.Gram,
	"kg": Mass.Kilogram,
	"ton": Mass.Ton,
}
const _OUNCE := {
	Mass.Ounce: 1.0,
	Mass.Gram: 28.3495,
	Mass.Pound: 0.0625,
	Mass.Kilogram: 0.0283495,
	Mass.Ton: 3.125e-5,
}
const _GRAM := {
	Mass.Ounce: 0.035274,
	Mass.Pound: 0.00220462,
	Mass.Gram: 1.0,
	Mass.Kilogram: 0.001,
	Mass.Ton: 1.10231e-6,
}
const _POUND := {
	Mass.Ounce: 16.0,
	Mass.Pound: 1.0,
	Mass.Gram: 453.592,
	Mass.Kilogram: 0.453592,
	Mass.Ton: 0.0005,
}
const _KILOGRAM := {
	Mass.Gram: 1000.0,
	Mass.Ounce: 35.274,
	Mass.Pound: 2.20462,
	Mass.Kilogram: 1.0,
	Mass.Ton: 0.00110231,
}
const _TON := {
	Mass.Gram: 907185.0,
	Mass.Ounce: 32000.0,
	Mass.Pound: 2000.0,
	Mass.Kilogram: 907.185,
	Mass.Ton: 1.0
}
const _MASS_CONVERT := {
	Mass.Ounce: _OUNCE,
	Mass.Pound: _POUND,
	Mass.Gram: _GRAM,
	Mass.Kilogram: _KILOGRAM,
	Mass.Ton: _TON,
}

static func mass(value: Variant, to: Variant, from: Variant = null) -> float:
	if value is String:
		# form: 0 unit
		if " " in value:
			var p = value.split(" ", true, 1)
			value = p[0].to_float()
			from = p[1]
		else:
			push_error("Can't convert length '%s'." % [value])
			return 0.0
	
	if to is String:
		to = _from_form(_MASS_FORMS, to)
	
	if from == null:
		push_error("Can't convert %s to %s: Unknown unit." % [value, Length.keys()[to]])
		return 0.0
	
	if from is String:
		from = _from_form(_MASS_FORMS, from)
	
	if from == to:
		return value
	
	if from in _MASS_CONVERT:
		if to in _MASS_CONVERT[from]:
			return value * _MASS_CONVERT[from][to]
		
		else:
			push_error("Can't convert from %s to %s." % [Mass.keys()[from], Mass.keys()[to]])
			return 0.0
	else:
		push_error("Can't convert %s." % [Mass.keys()[from]])
		return 0.0

static func _from_form(d: Dictionary, form: String) -> int:
	return d[form.trim_suffix(".")]
