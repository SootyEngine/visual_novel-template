@tool
extends Node
class_name TestClass

@export var health := 4321
var _data := {x="true"}
var EXO := Vector2.ZERO

func damage(amount := 0, kwargs := {}):
	print("Damaged %s! (%s)" % [amount, kwargs])

func heal(amount := 0):
	print("Healed %s!" % amount)

func _get(property: StringName):
	return _data.get(property)

func testy(none:="a", x :bool= true, y := "okay", color := EXO, kwargs := {}):
	prints("Got none:%s, x:%s y:%s color:%s, kwra:%s" % [none, x, y, color, kwargs])
	return 0
