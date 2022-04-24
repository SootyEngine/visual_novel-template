extends Data
class_name Award, "res://addons/visual_novel/objects/Award.gd"
func get_class() -> String:
	return "Award"

const MSG_PROGRESS := "award_progress"
const MSG_UNLOCKED := "award_unlocked"

var name := ""
var desc := ""
var toll := 1
var hide := true
var lock := false
var icon := "res://icon.png"
var date := 0

var tick := 0:
	set(x):
		tick = clampi(x, 0, toll)
		if is_completed():
			date = DateTime.create_from_current().total_seconds

func is_active() -> bool:
	return tick > 0

func is_completed() -> bool:
	return tick == toll

# advance the awards progress, or complete
func advance(amount: int = 1):
	if not is_completed():
		if tick == toll-1:
			complete()
		else:
			Global.notify({
				type=MSG_PROGRESS,
				text=[name, desc],
				prog=get_progress(),
				play="award_progress"
			})

func complete() -> void:
	if not is_completed():
		tick = toll
		
		Global.notify({
			type=MSG_UNLOCKED,
			text=[ "[yellow_green]Achieved[] %s" % name, desc ],
			play="award_got"
		})

func get_progress() -> float:
	return 0.0 if tick==0 or toll==0 else float(tick) / float(toll)
