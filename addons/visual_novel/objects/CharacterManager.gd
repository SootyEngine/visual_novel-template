@tool
extends DataManager
class_name CharacterManager, "res://addons/visual_novel/icons/people.png"
func get_class() -> String:
	return "CharacterManager"

func _get_data_class() -> String:
	return "Character"
