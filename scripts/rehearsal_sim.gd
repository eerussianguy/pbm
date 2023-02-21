extends Control

const TOTAL_TIME = 30

var time = 0
var paused = false
var event: RehearsalEvent
var last_polled = -1
var complete = false

var queue: Dictionary = {}

func _ready():
	_generate_events()

func _process(delta):
	if not paused:
		time += delta
		if Input.is_action_pressed("ui_accept"):
			time += 0.1
		if time - last_polled > 1:
			_poll_events()
			last_polled = time
	if time >= TOTAL_TIME and not complete:
		complete = true
		_complete()
	$Panel/VB/ProgressBar.value = time

func _complete():
	paused = true
	$Panel/VB/PauseBtn.disabled = true
	$Panel/VB/DoneBtn.disabled = false
	$Panel/VB/Label.text = "Rehearsal complete!"
	_poll_events()
	_modify_members()

func _modify_members():
	var participated = 0
	var exhausted = 0
	var near_exhausted = 0
	var happier = 0
	var repeats = is_repeat()
	for member in Global.savegame.roster:
		if member.exhaustion > 90:
			exhausted += 1
		else:
			participated += 1
			if member.exhaustion > 70:
				member.add_happiness(-10)
				near_exhausted += 1
			elif member.exhaustion > 50:
				member.add_happiness(5)
				happier += 1
			else:
				member.add_happiness(10)
				happier += 1
			if member.technical < 30 or member.intonation < 30:
				member.add_happiness(2)
			member.add_exhaustion(10)
			if repeats:
				member.add_exhaustion(3)
				member.add_happiness(-3)
	text("%s members participated, %s skipped due to exhaustion" % [participated, exhausted])
	if near_exhausted > 0:
		text("%s members were unhappy with having to rehearse because of their exhaustion" % near_exhausted)
	if happier > 0:
		text("%s members became happier due to the rehearsal." % happier)
	if repeats:
		text("Everyone lost happiness and gained exhaustion because they rehearsed the same song more than once.")
	
	
	Global.set_roster(Global.savegame.roster)

func is_repeat() -> bool:
	return (event.songs_to_rehearse[0].title == event.songs_to_rehearse[1].title) or (event.songs_to_rehearse[1].title == event.songs_to_rehearse[2].title) or (event.songs_to_rehearse[0].title == event.songs_to_rehearse[2].title)

func text(statement):
	var txt = $Panel/VB/ColorRect/Updates
	txt.newline()
	txt.append_text(statement)

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
	var songs = event.songs_to_rehearse
	var dict = {
		0: "Students are entering the band room.",
		5: "Starting to rehearse %s..." % [songs[0].title],
		10: "Finished rehearsing %s" % [songs[0].title],
		11: "Starting to rehearse %s..." % [songs[1].title],
		16: "Finished rehearsing %s" % [songs[1].title],
		17: "Starting to rehearse %s..." % [songs[2].title],
		22: "Finished rehearsing %s" % [songs[2].title],
		23: "Band director is giving a speech to the students...",
		24: "They are impressing the importance of being on time to rehearsal...",
		25: "Students are beginning to leave...",
		30: "All students have left the band room."
	}
	queue = dict

func now() -> String:
	var total = int(time * 3) + (60 * 6)
	var mins = total % 60
	var hrs = int(float(total) / 60)
	return "%s:%s" % [var_to_str(hrs).pad_zeros(2), var_to_str(mins).pad_zeros(2)]
