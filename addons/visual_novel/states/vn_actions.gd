@tool
extends Node


# databases
var data := Database.new() # unorganized data
var inventories := InventoryDatabase.new()
var items := ItemDatabase.new()
var characters := CharacterDatabase.new()
var goals := GoalDatabase.new()
var locations := LocationDatabase.new()
var equipment_slots := EquipmentSlotDatabase.new()

func _init() -> void:
	StringAction.connect_methods(self, [
		# flags
		has_flag, flag,
		# goals
		goal_started, goal_failed, goal_passed, goal_advanced,
		# items
		gained, lost,
		# stats
		gained_stat
	])


# checks that a state flag is set, typicall a bool.
func has_flag(flag: String) -> bool:
	flag = "flags.%s" % flag
	if State._has(flag):
		return true if State._get(flag) else false
	push_error("No flag property %s." % [flag])
	return false


# set's a state flag, typically a bool.
func flag(flag: String, to: Variant = true):
	flag = "flags.%s" % flag
	if State._has(flag):
		State._set(flag, to)
	else:
		push_error("No flag property %s." % flag)

#
# GOAL RELATED
#

# start a goal
func goal_started(goal: String, kwargs := {}):
	goals.start(goal)

func goal_advanced(goal: String, kwargs := {}):
	goals.start(goal)

func goal_failed(goal: String, kwargs := {}):
	goals.start(goal)

func goal_passed(goal: String, kwargs := {}):
	goals.start(goal)


#
# INVENTORY RELATED
#
func gained(item: Item, quantity: int, kwargs := {}):
	var from: String = kwargs.get("from", "")
	var to: String = kwargs.get("to", "p") # player by default
	if to:
		var inv_to: Inventory = characters.find(to).inventory
		inv_to.gain(item, quantity, kwargs)
	if from:
		var inv_from: Inventory = characters.find(from).inventory
		inv_from.lose(item, quantity, kwargs)

func lost(item: Item, amount: int, kwargs := {}):
	gained(item, -amount, kwargs)

#
# STAT RELATED
#
func gained_stat(stat: String, amount: int = 1, kwargs := {}):
	var whom: String = kwargs.get("who", "p") # player by default
	var character: Character = characters.find(whom)
	# TODO: do this in a way it will trigger the State.changed signal
	if stat in character:
		character[stat] += amount
