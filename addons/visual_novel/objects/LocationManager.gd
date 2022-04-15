@tool
extends DataManager
class_name LocationManager, "res://addons/visual_novel/icons/locations.png"
func get_class():
	return "LocationManager"

func _get_data_class():
	return "Location"
