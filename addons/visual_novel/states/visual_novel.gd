@tool
extends Node

var _shortcuts := {
	p="characters.player",
	inv="characters.player.inventory"
}

# databases
var time: DateTime = DateTime.new({weekday="sat"})
var data := Database.new(Data) # misc data
var traits := Database.new(Trait) # unchanging properties of characters, items, locations...
var stats := Database.new(Stat) # like traits, but changeable.
var inventories := Database.new(Inventory) # inventories disconnected from characters and locations
var inventory_items := Database.new(InventoryItem)
var items := Database.new(Item)
var characters := Database.new(Character, {
	# always have a default character
	# doesn't have to be used
	player=Character.new({name="player"})
})
var goals := Database.new(Goal)
var locations := Database.new(Location)
var equipment_slots := Database.new(EquipmentSlot)

func _init() -> void:
	Sooty.actions.connect_methods([
		# time
		advance_time,
		# flags
		has_flag, flag,
		# goals
		goal_started, goal_failed, goal_passed, goal_advanced,
		# items
#		gain, lose, has_item,
		# stats
		gain_stat
	])

# output a property in a formatted way
func show(property: String, for_what: String = "") -> String:
	var path := property.split(".")
	var obj = UObject.get_penultimate(Sooty.state, path)
	if obj:
		if obj.has_method("get_string"):
			return obj.get_string(path[-1], for_what)
		else:
			return str(obj.get(path[-1]))
	else:
		return "<?%s?>" % [property]

func advance_time(kwargs := {}):
	time.advance(kwargs)

# checks that a state flag is set, typicall a bool.
func has_flag(flag: String) -> bool:
	flag = "flags.%s" % flag
	if Sooty.state._has(flag):
		return true if Sooty.state._get(flag) else false
	push_error("No flag property %s." % [flag])
	return false


# set's a state flag, typically a bool.
func flag(flag: String, to: Variant = true):
	flag = "flags.%s" % flag
	if Sooty.state._has(flag):
		Sooty.state._set(flag, to)
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


##
## INVENTORY RELATED
##
#func gain(item: Item, amount: int, kwargs := {}):
#	var from: String = kwargs.get("from", "")
#	var who: String = kwargs.get("who", "p") # player by default
#	if who:
#		var inv_to: Inventory = characters.find(who).inventory
#		inv_to.gain(item, amount)
#	if from:
#		var inv_from: Inventory = characters.find(from).inventory
#		inv_from.lose(item, amount)
#
#func lose(item: Item, amount: int, kwargs := {}):
#	var to: String = kwargs.get("to", "")
#	var who: String = kwargs.get("who", "p") # player by default
#	if who:
#		var inv_to: Inventory = characters.find(who).inventory
#		inv_to.lose(item, amount)
#	if to:
#		var inv_from: Inventory = characters.find(to).inventory
#		inv_from.gain(item, amount)
#
#func has_item(item: Item, amount: int = 1, kwargs := {}) -> bool:
#	var c: Character = characters.find(kwargs.get("who", "p"))
#	return c.inventory.has(item, amount) if c else false
#
#func has_items(itms: Array, kwargs := {}) -> bool:
#	var c: Character = characters.find(kwargs.get("who", "p"))
#	return c.inventory.has_all(item, amount)

#
# STAT RELATED
#
func gain_stat(stat: String, amount: int = 1, kwargs := {}):
	var whom: String = kwargs.get("who", "p") # player by default
	var character: Character = characters.find(whom)
	# TODO: do this in a way it will trigger the State.changed signal
	if stat in character:
		character[stat] += amount
