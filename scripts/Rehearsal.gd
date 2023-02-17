extends Control

var selected = null

var song1: Song = null
var song2: Song = null
var song3: Song = null

var day1 = 0
var day2 = 0

func _ready():
	_update_view()


func _process(_delta):
	pass


func _update_view():
	if selected != null:
		$Panel/Title.text = selected.title
		$Panel/Info.clear()
		$Panel/Info.append_text("by %s\n%s\nDifficulty: %s" % [selected.author, selected.copyright_credit, var_to_str(selected.difficulty)])
		
	var list = $ItemList
	list.clear()
	var id = 0
	var selection = 0
	for song in Global.SONGS:
		list.add_item("%s -- %s" % [song.title, song.author], null, true)
		list.set_item_metadata(id, song)
		if selected != null and selected == song:
			selection = id
		id += 1
	list.select(selection, true)
	
	$TabContainer/Planning/GridContainer/FirstLabel.text = song1.title + " (%s)" % [var_to_str(song1.difficulty)] if song1 != null else "No Song Selected"
	$TabContainer/Planning/GridContainer/SecondLabel.text = song2.title + " (%s)" % [var_to_str(song2.difficulty)] if song2 != null else "No Song Selected"
	$TabContainer/Planning/GridContainer/ThirdLabel.text = song3.title + " (%s)" % [var_to_str(song3.difficulty)] if song3 != null else "No Song Selected"
	
	day1 = 0
	day2 = 0
	var dt = Global.savegame.datetime
	for i in range(0, 14):
		dt += Global.SECONDS_IN_DAY # don't allow same day scheduling
		if Global.day_of_week(dt) == 3:
			if day1 == 0:
				day1 = dt
			elif day2 == 0:
				day2 = dt
				break
	
	var day1dict = Time.get_date_dict_from_unix_time(day1)
	var day2dict = Time.get_date_dict_from_unix_time(day2)
	$TabContainer/Planning/VBoxContainer/ScheduleSoonBtn.text = "Schedule on %s/%s" % [day1dict["month"], day1dict["day"]]
	$TabContainer/Planning/VBoxContainer/ScheduleLaterBtn.text = "Schedule on %s/%s" % [day2dict["month"], day2dict["day"]]
	
	
	var songs_exist = song1 != null and song2 != null and song3 != null
	var disab1 = day1 == 0 or not songs_exist
	var disab2 = day2 == 0 or not songs_exist
	for event in Global.savegame.events:
		if event.date == day1:
			disab1 = true
		if event.date == day2:
			disab2 = true
	
	$TabContainer/Planning/VBoxContainer/ScheduleSoonBtn.disabled = disab1
	$TabContainer/Planning/VBoxContainer/ScheduleLaterBtn.disabled = disab2
	
	var diff: float = 0.0
	var count = 0
	if song1 != null:
		diff += song1.difficulty
		count += 1
	if song2 != null:
		diff += song2.difficulty
		count += 1
	if song3 != null:
		diff += song3.difficulty
		count += 1
	diff = diff / count
	if count == 0:
		diff = 0
	var info = $TabContainer/Planning/VBoxContainer/Info
	info.clear()
	info.append_text("Rehearsal Difficulty: %s" % [var_to_str(floor(diff * 10) / 10)])


func _on_item_list_item_selected(index):
	selected = $ItemList.get_item_metadata(index)
	_update_view()
	

func _on_replace_first_btn_pressed():
	if selected != null:
		song1 = selected
	_update_view()

func _on_remove_first_btn_pressed():
	song1 = null
	_update_view()

func _on_replace_second_btn_pressed():
	if selected != null:
		song2 = selected
	_update_view()

func _on_remove_second_btn_pressed():
	song2 = null
	_update_view()

func _on_replace_third_btn_pressed():
	if selected != null:
		song3 = selected
	_update_view()


func _on_remove_third_btn_pressed():
	song3 = null
	_update_view()


func _on_schedule_soon_btn_pressed():
	_make_rehearsal(day1)


func _on_schedule_later_btn_pressed():
	_make_rehearsal(day2)

func _make_rehearsal(date):
	var reh = RehearsalEvent.new()
	reh.songs_to_rehearse = [song1, song2, song3]
	reh.date = date
	reh.time = "6:00pm"
	reh.location = "Band Room"
	
	_clear_planner()
	Global.savegame.events.append(reh)
	Global.set_events(Global.savegame.events)

func _clear_planner():
	song1 = null
	song2 = null
	song3 = null

func _on_events_updated():
	_update_view()
