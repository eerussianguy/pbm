extends Event
class_name GameEvent

@export var team: String = "team"
@export var vs: String = "otherteam"

func mih(p_date, p_vs):
	date = p_date
	vs = p_vs
	team = "MIH"
	location = "Alumni Arena"
	time = "5:45pm" if randi() % 1 == 0 else "6:45pm"
	return self

func wih(p_date, p_vs):
	date = p_date
	vs = p_vs
	team = "WIH"
	location = "Historic Arena"
	time = "5:15pm" if randi() % 1 == 0 else "6:15pm"
	return self

func mbb(p_date, p_vs):
	date = p_date
	vs = p_vs
	team = "MBB"
	location = "Basement Gym"
	time = "3:45pm" if randi() % 1 == 0 else "7:15pm"
	return self

func wbb(p_date, p_vs):
	date = p_date
	vs = p_vs
	team = "WBB"
	location = "Basement Gym"
	time = "3:45pm" if randi() % 1 == 0 else "7:15pm"
	return self
