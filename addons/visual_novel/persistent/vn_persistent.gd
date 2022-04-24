@tool
extends Node

# achievements are saved across playthroughs
var awards := Database.new(Award)
var rewards := Database.new(Reward)

func _init() -> void:
	StringAction.connect_methods(self, [
		has_award, gain_award,
		has_reward, gain_reward
	])

# gain an achievement
func gain_award(award: Award):
	award.achieve()

# check if achievement is unlocked
func has_award(award: String) -> bool:
	return awards.is_unlocked(award)

func has_reward(id: String) -> bool:
	return rewards.find(id).is_unlocked()

func gain_reward(id: String):
	rewards.achieve(id)
