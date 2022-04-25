extends Node

func setup(info: Dictionary):
	var stat: Stat = info.stat
	var base: int = info.base
	var current: int = info.current
	# TODO: Show change from baseline due to whats begin worn + traits.
	
	# icon
	$icon.set_texture(stat.get_icon())
	# stat name and description
	$info/info.set_bbcode("[h1]%s[]\n[]%s" % [stat.name, stat.desc])
	
	# progress bar
	$info/progress/progress.value = current
	$info/progress/progress.max_value = stat.max
	
	# progress text
	$info/progress/level.set_bbcode("[h1]%s[;dim]/[]%s" % [current, stat.max])
	
	name = info.id
