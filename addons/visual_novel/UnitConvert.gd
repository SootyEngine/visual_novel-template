@tool
extends RefCounted
class_name Unit

# TODO: These numbers are mostly Googled, and untested.

enum Dist { Inch, Foot, Centimeter, Meter, Kilometer, Mile }
enum Mass { Gram, Pound, Ounce, Kilogram, Ton }
enum Temp { Celsius, Farenheit, Kelvin }

const _DIST_FORMS := {
	"in": Dist.Inch,
	"ft": Dist.Foot,
	"cm": Dist.Centimeter,
	"m": Dist.Meter,
	"km": Dist.Kilometer,
	"mi": Dist.Mile
}

const _INCH := {
	Dist.Centimeter: 2.54,
	Dist.Inch: 1.0,
	Dist.Foot: 0.0833333,
	Dist.Mile: 1.57828e-5,
	Dist.Kilometer: 2.54e-5,
}

const _FOOT := {
	Dist.Centimeter: 30.48,
	Dist.Inch: 12.0,
	Dist.Foot: 1.0,
	Dist.Meter: 0.3048,
	Dist.Kilometer: 0.0003048,
	Dist.Mile: 0.000189394,
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

const _CENTIMETER := {
	Dist.Inch: 0.393701,
	Dist.Foot: 0.0328084,
	Dist.Meter: 0.01,
	Dist.Centimeter: 1.0,
	Dist.Kilometer: 1e-5,
	Dist.Mile: 6.21371e-6
}
const _LENGTH_CONVERT := {
	Dist.Inch: _INCH,
	Dist.Foot: _FOOT,
	Dist.Meter: _METER,
	Dist.Centimeter: _CENTIMETER,
	Dist.Kilometer: _KILOMETER,
	Dist.Mile: _MILE,
}

static func length(value: Variant, to: Variant, from: Variant = null) -> float:
	if value is String:
		# form: 0'0"
		if "'" in value:
			var p = value.split("'", true, 1)
			var feet = p[0]
			var inches = "0" if not '"' in p[1] else p[1].split('"', true, 1)[0]
			value = feet.to_float() * 12.0 + inches.to_float()
			from = Dist.Inch
		# form: 0 unit
		elif " " in value:
			var p = value.split(" ", true, 1)
			value = p[0].to_float()
			from = p[1]
		else:
			push_error("Can't convert length '%s'." % [value])
	
	if to is String:
		to = _from_form(_DIST_FORMS, from)
	
	if from == null:
		push_error("Can't convert %s to %s: Unknown unit. Leaving unconverted." % [value, Dist.keys()[to]])
		return value
	
	if from is String:
		from = _from_form(_DIST_FORMS, from)
	
	if from == to:
		return value
	
	if from in _LENGTH_CONVERT:
		if to in _LENGTH_CONVERT[from]:
			return value * _LENGTH_CONVERT[from][to]
		
		else:
			push_error("Can't convert from %s to %s." % [Dist.keys()[from], Dist.keys()[to]])
			return 0.0
	else:
		push_error("Can't convert %s." % [Dist.keys()[from]])
		return 0.0

static func to_feet_and_inches(inches: float) -> String:
	inches = ceil(inches)
	return "%s'%s\"" % [int(inches / 12), int(inches) % 12]

const _MASS_FORMS := {
	"oz": Mass.Ounce,
	"ozs": Mass.Ounce,
	"lb": Mass.Pound,
	"lbs": Mass.Pound,
	"g": Mass.Gram,
	"gs": Mass.Gram,
	"kg": Mass.Kilogram,
	"kgs": Mass.Kilogram,
	"ton": Mass.Ton,
	"tons": Mass.Ton
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
		push_error("Can't convert %s to %s: Unknown unit." % [value, Dist.keys()[to]])
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

const _TEMP_FORMS := {
	"k": Temp.Kelvin,
	"f": Temp.Farenheit,
	"c": Temp.Celsius,
}

static func temp(value: Variant, to: Variant, from: Variant = null) -> float:
	if value is String:
		# form: 0 unit
		if " " in value:
			var p = value.split(" ", true, 1)
			value = p[0].to_float()
			from = p[1]
		else:
			push_error("Can't convert temp '%s'." % [value])
			return 0.0
	
	if to is String:
		to = _from_form(_TEMP_FORMS, to)
	
	if from == null:
		push_error("Can't convert %s to %s: Unknown unit." % [value, Temp.keys()[to]])
		return 0.0
	
	if from is String:
		from = _from_form(_TEMP_FORMS, from)
	
	if from == to:
		return value
	
	match [from, to]:
		[Temp.Celsius, Temp.Farenheit]: return value * 1.8 + 32.0
		[Temp.Celsius, Temp.Kelvin]: return value + 273.15
		[Temp.Farenheit, Temp.Celsius]: return (value - 32.0) / 1.8
		[Temp.Farenheit, Temp.Kelvin]: return 5.0 * (value - 32.0) / 9.0 + 273.15
		[Temp.Kelvin, Temp.Celsius]: return value - 273.15
		[Temp.Kelvin, Temp.Farenheit]: return value * 1.8 - 459.67
		_: return 0.0
