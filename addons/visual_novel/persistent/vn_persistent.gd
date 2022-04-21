@tool
extends Node

# achievements are saved across playthroughs
var awards := AwardDatabase.new()
var rewards := RewardDatabase.new()

func _init() -> void:
	StringAction.connect_methods(self, [
		has_award, gain_award,
		has_reward, gain_reward
		])

# gain an achievement
func gain_award(award: String):
	awards.achieve(award)

# check if achievement is unlocked
func has_award(award: String) -> bool:
	return awards.is_unlocked(award)

func has_reward(id: String) -> bool:
	return rewards.find(id).is_unlocked()

func gain_reward(id: String):
	rewards.achieve(id)
