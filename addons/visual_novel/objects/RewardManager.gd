@tool
extends Database
class_name RewardDatabase
func get_class() -> String:
	return "RewardDatabase"

func _get_data_class() -> String:
	return "Reward"
