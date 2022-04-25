extends PatchableData
class_name Character, "res://addons/visual_novel/icons/person.png"
func get_class() -> String:
	return "Character"
func _get_database_id():
	return "Character"

var name := ""
var surname := ""
var gender := ""
var at := ""
var birthday: DateTime = DateTime.new()
var inventory: Inventory = Inventory.new()
var traits: Traits = Traits.new()
var stats: Stats = Stats.new()


func _get(property: StringName):
	var k := str(property)
	# TODO: Grammar pronouns
	return super._get(property)
