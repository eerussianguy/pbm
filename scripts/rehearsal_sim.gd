extends Control

const TOTAL_TIME = 30

var time = 0
var paused = false
var event: RehearsalEvent
var last_polled = -1

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
	if time >= TOTAL_TIME:
		_complete()
	$Panel/VB/ProgressBar.value = time

func _complete():
	paused = true
	$Panel/VB/PauseBtn.disabled = true
	$Panel/VB/DoneBtn.disabled = false
	$Panel/VB/Label.text = "Rehearsal complete!"
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
