extends Control

var view_datetime = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	view_datetime = Global.savegame.datetime
	update_view()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func update_view():
	var date_of_sunday = view_datetime
	var idx = Global.day_of_week(view_datetime)
	var today = idx
	while idx != 0:
		date_of_sunday -= Global.SECONDS_IN_DAY
		idx = Global.day_of_week(date_of_sunday)
	
	var infos = [
		Time.get_date_dict_from_unix_time(date_of_sunday),
		Time.get_date_dict_from_unix_time(date_of_sunday + Global.SECONDS_IN_DAY),
		Time.get_date_dict_from_unix_time(date_of_sunday + (2 * Global.SECONDS_IN_DAY)),
		Time.get_date_dict_from_unix_time(date_of_sunday + (3 * Global.SECONDS_IN_DAY)),
		Time.get_date_dict_from_unix_time(date_of_sunday + (4 * Global.SECONDS_IN_DAY)),
		Time.get_date_dict_from_unix_time(date_of_sunday + (5 * Global.SECONDS_IN_DAY)),
		Time.get_date_dict_from_unix_time(date_of_sunday + (6 * Global.SECONDS_IN_DAY))
	]
	
	var days = [
		$Week/Sunday,
		$Week/Monday,
		$Week/Tuesday,
		$Week/Wednesday,
		$Week/Thursday,
		$Week/Friday,
		$Week/Saturday
	]
	
	$Week/Sunday/DayLabel.text = "%s Sun" % infos[0]["day"]
	$Week/Monday/DayLabel.text = "%s Mon" % infos[1]["day"]
	$Week/Tuesday/DayLabel.text = "%s Tue" % infos[2]["day"]
	$Week/Wednesday/DayLabel.text = "%s Wed" % infos[3]["day"]
	$Week/Thursday/DayLabel.text = "%s Thu" % infos[4]["day"]
	$Week/Friday/DayLabel.text = "%s Fri" % infos[5]["day"]
	$Week/Saturday/DayLabel.text = "%s Sat" % infos[6]["day"]

	$MonthYear.text = "%s %s" % [Global.MONTHS[infos[0]["month"] - 1], infos[0]["year"]]
	
	for day in days:
		for c in day.get_node("GigList").get_children():
			c.queue_free()
	
	for e in Global.savegame.events:
		var ed = e.date
		if ed >= date_of_sunday and ed <= date_of_sunday + (6 * Global.SECONDS_IN_DAY):
			for i in range(0, 7):
				if (i * Global.SECONDS_IN_DAY + date_of_sunday) == ed:
					make_gig_panel(days[i], e)
	
	var lab = null
	for label in get_tree().get_nodes_in_group("Today"):
		if lab == null:
			lab = label.duplicate()
		label.queue_free()
	if lab != null:
		days[today].get_node("Panel").add_child(lab)
		lab.visible = view_datetime == Global.savegame.datetime

func make_gig_panel(parent, event):
	var list = parent.get_node("GigList")
	var panel = load("res://scenes/gig_panel.tscn").instantiate()
	panel.metadata = event
	if event is GameEvent:
		panel.get_node("Label").text = "%s vs %s" % [event.team, event.vs]
	elif event is RehearsalEvent:
		panel.get_node("Label").text = "Scheduled Rehearsal"
	var info = panel.get_node("Info")
	info.clear()
	info.append_text(event.time)
	info.newline()
	info.append_text(event.location)
	list.add_child(panel)
	

func _on_events_updated():
	update_view()

func _on_date_updated():
	view_datetime = Global.savegame.datetime
	update_view()

func _on_back_week_btn_pressed():
	view_datetime -= (Global.SECONDS_IN_DAY * 7)
	update_view()


func _on_forward_week_btn_pressed():
	view_datetime += (Global.SECONDS_IN_DAY * 7)
	update_view()

func _on_reset_button_pressed():
	view_datetime = Global.savegame.datetime
	update_view()

func _on_advance_btn_pressed():
	get_tree().current_scene.add_child(load("res://scenes/time_advancer.tscn").instantiate())
