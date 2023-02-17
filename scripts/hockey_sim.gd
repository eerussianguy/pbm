extends Control

const TOTAL_TIME = 90

var time = 0
var paused = false
var event: GameEvent
var last_polled = -1

var queue: Dictionary = {}

@onready var pregame = $Panel/VB/Periods/Pregame
@onready var one = $Panel/VB/Periods/One
@onready var two = $Panel/VB/Periods/Two
@onready var three = $Panel/VB/Periods/Three
@onready var postgame = $Panel/VB/Periods/Postgame


func _ready():
	_generate_events()
	$Panel/VB/Title.text = "%s vs %s" % [event.team, event.vs]

func _process(delta):
	if not paused:
		time += delta
		if Input.is_action_pressed("ui_accept"):
			time += 0.1
		if time - last_polled > 1:
			_poll_events()
			last_polled = time
	if time >= TOTAL_TIME:
		_complete()
	if time < 15:
		pregame.value = time
	elif time < 35:
		pregame.value = 15
		one.value = time
	elif time < 55:
		two.value = time
		one.value = 35
	elif time < 75:
		three.value = time
		two.value = 55
	else:
		postgame.value = time
		three.value = 75

func _complete():
	paused = true
	$Panel/VB/PauseBtn.disabled = true
	$Panel/VB/DoneBtn.disabled = false
	$Panel/VB/Label.text = "Game over!"
	_poll_events()


func _on_done_btn_pressed():
	Global.savegame.events.erase(event)
	Global.savegame.old_events.append(event)
	Global.set_events(Global.savegame.events)
	queue_free()


func _on_pause_btn_toggled(button_pressed):
	paused = button_pressed
	if paused:
		$Panel/VB/Label.text = "Time paused..."
	else:
		$Panel/VB/Label.text = "Time marches on..."

func _poll_events():
	var to_erase = -1
	for q in queue.keys():
		if time > q:
			var txt = $Panel/VB/ColorRect/Updates
			if q > 0:
				txt.newline()
			txt.append_text("%s -- %s" % [now(), queue[q]])
			to_erase = q
			break
	if to_erase != -1:
		queue.erase(to_erase)


func _generate_events():
	var dict = {
		0: "Band members have begun filling the stands.",
		5: "The band is ready.",
		15: "The first period is starting.",
		30: "The first period is complete.",
		35: "The second period is starting.",
		50: "The second period is complete.",
		55: "The third period is starting.",
		70: "The third period is complete.",
		85: "The band is beginning to leave the arena.",
		90: "The band has left the arena."
	}
	
	var home_score = 0
	var away_score = 0
	for i in range(0, 90):
		if (15 < i and i < 30) or (35 < i and i < 50) or (55 < i and i < 70):
			if randi() % 6 == 0:
				if randi() % 2 == 0:
					home_score += 1
					dict[i] = "%s goal! Score: %s" % [event.team, get_score(home_score, away_score)]
				else:
					away_score += 1
					dict[i] = "%s goal! Score: %s" % [event.vs, get_score(home_score, away_score)]
	
	if home_score == away_score:
		dict[71] = "Neither team managed to win in regulation. It's time for overtime!"
		if randi() % 2 == 0:
			home_score += 1
			dict[72] = "An overtime goal for %s! Score: %s" % [event.team, get_score(home_score, away_score)]
		else:
			away_score += 1
			dict[72] = "An overtime goal for %s! Score: %s" % [event.vs, get_score(home_score, away_score)]
	
	if home_score > away_score:
		dict[73] = "Victory! The band is elated and is celebrating the team's victory. Final score: %s" % [get_score(home_score, away_score)]
	else:
		dict[73] = "The team lost! The band is sad, but lifts the spirts of the crowd with music. Final score: %s" % [get_score(home_score, away_score)]
	
	queue = dict

func get_score(home_score, away_score) -> String:
	return "%s %s - %s %s" % [event.team, home_score, event.vs, away_score]

func now() -> String:
	var total = int(time * 1.2) + (60 * 6)
	var mins = total % 60
	var hrs = int(float(total) / 60)
	return "%s:%s" % [var_to_str(hrs).pad_zeros(2), var_to_str(mins).pad_zeros(2)]

