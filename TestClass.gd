class_name TestClass

var name := ""
var _data := {x="true"}
var EXO := Vector2.ZERO

func _get(property: StringName):
	return _data.get(property)

func testy(none:="a", x :bool= true, y := "okay", color := EXO, kwargs := {}):
	prints("Got none:%s, x:%s y:%s color:%s, kwra:%s" % [none, x, y, color, kwargs])
	return 0
