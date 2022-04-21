@tool
extends Node

# achievements are saved across playthroughs
var awards := AwardDatabase.new()

func _init() -> void:
	StringAction.connect_methods(self, [has_award, achieved])

# gain an achievement
func achieved(award: String):
	awards.achieve(award)

# check if achievement is unlocked
func has_award(award: String) -> bool:
	return awards.is_unlocked(award)
