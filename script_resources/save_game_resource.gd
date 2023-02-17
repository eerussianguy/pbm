extends Resource
class_name SaveGameResource

@export var roster: Array[Member] = []
@export var events: Array[Event] = []
@export var old_events: Array[Event] = []
@export var tasks: Array[Task] = []
@export var old_tasks: Array[Task] = []
@export var emails: Array[Email] = []
@export var old_emails: Array[Email] = []
@export var datetime: int = 0
@export var recurring_expenses: Array[Expense] = []
@export var transactions: Array[Expense] = []
@export var cash: int = 0
@export var section_leaders: Dictionary = {}
@export var song_skill_levels: Dictionary = {}

func init_fresh_game():
	initialize_date()
	make_random_roster()
	make_random_events()
	make_tutorial_tasks()
	make_tutorial_emails()
	make_recurring_expenses()
	cash = 10000

func initialize_date():
	datetime = Time.get_unix_time_from_datetime_dict({
		"year": 2001,
		"month": 8,
		"day": 26
	})

func make_random_roster():
	var male = FileAccess.open("res://male.json", FileAccess.READ)
	var female = FileAccess.open("res://female.json", FileAccess.READ)
	var last = FileAccess.open("res://last.json", FileAccess.READ)
	var male_json = JSON.parse_string(male.get_as_text(true))["names"]
	var female_json = JSON.parse_string(female.get_as_text(true))["names"]
	var last_json = JSON.parse_string(last.get_as_text(true))["names"]
	
	roster.clear()
	for i in range(0, 50):
		var mem := Member.new()
		mem.new_member(male_json, female_json, last_json, i)
		roster.append(mem)
	
	# notably this does not assign the highest skill level to SL
	for mem in roster:
		var key = mem.instrument.name
		if !section_leaders.has(key):
			section_leaders[key] = mem
		elif section_leaders[key].year < mem.year:
			section_leaders[key] = mem
	
	# This is the documented way to free the file objects (since there is apparently no way to flush)
	male = null
	female = null
	last = null


func make_random_events():
	var mih_games = Global.HOCKEY_TEAMS.keys()
	mih_games.append_array(Global.HOCKEY_TEAMS.keys())
	mih_games.append_array(Global.HOCKEY_TEAMS.keys())
	mih_games.shuffle()
	var wih_games = Global.HOCKEY_TEAMS.keys()
	wih_games.append_array(Global.HOCKEY_TEAMS.keys())
	wih_games.append_array(Global.HOCKEY_TEAMS.keys())
	wih_games.shuffle()
	var next_mih_friday = randi_range(0, 1) == 0
	var next_wih_friday = randi_range(0, 1) == 0
	var mbb_games = Global.BASKETBALL_TEAMS.keys()
	mbb_games.append_array(Global.BASKETBALL_TEAMS.keys())
	mbb_games.shuffle()
	var wbb_games = Global.BASKETBALL_TEAMS.keys()
	wbb_games.append_array(Global.BASKETBALL_TEAMS.keys())
	wbb_games.shuffle()
	var next_mbb_wednesday = randi_range(0, 1) == 0
	var next_wbb_wednesday = randi_range(0, 1) == 0
	for i in range(0, 300):
		var date = Global.savegame.datetime + (i * Global.SECONDS_IN_DAY)
		var info = Time.get_date_dict_from_unix_time(date)
		var day = info["day"]
		var month = info["month"]
		var weekday = info["weekday"]
		
		if ((month == 9 and day > 10) or month > 9) or (month < 2 or (month == 2 and day < 15)):
			if len(mih_games) > 0:
				if weekday == 5 and next_mih_friday:
					events.append(GameEvent.new().mih(date, mih_games.pop_front()))
					next_mih_friday = not next_mih_friday
				elif weekday == 6 and not next_mih_friday:
					events.append(GameEvent.new().mih(date, mih_games.pop_front()))
					next_mih_friday = randi_range(0, 1) == 0
			if len(wih_games) > 0:
				if weekday == 5 and next_wih_friday:
					events.append(GameEvent.new().wih(date, wih_games.pop_front()))
					next_wih_friday = randi_range(0, 1) == 0
				elif weekday == 6 and not next_mih_friday:
					events.append(GameEvent.new().wih(date, wih_games.pop_front()))
					next_wih_friday = not next_wih_friday
		if ((month == 10 and day > 10) or month > 10) or (month < 2 or (month == 2 and day < 15)):
			if len(mbb_games) > 0 and randi_range(0, 2) == 0:
				if weekday == 1 and not next_mbb_wednesday:
					events.append(GameEvent.new().mbb(date, mbb_games.pop_front()))
					next_mbb_wednesday = randi_range(0, 1) == 0
				elif weekday == 3 and next_mbb_wednesday:
					events.append(GameEvent.new().mbb(date, mbb_games.pop_front()))
					next_mbb_wednesday = not next_mbb_wednesday
				elif weekday == 2 and randi_range(0, 5) == 0:
					events.append(GameEvent.new().mbb(date, mbb_games.pop_front()))
			if len(wbb_games) > 0 and randi_range(0, 2) == 0:
				if weekday == 1 and not next_wbb_wednesday:
					events.append(GameEvent.new().wbb(date, wbb_games.pop_front()))
					next_wbb_wednesday = not next_wbb_wednesday
				elif weekday == 3 and next_wbb_wednesday:
					events.append(GameEvent.new().wbb(date, wbb_games.pop_front()))
					next_wbb_wednesday = randi_range(0, 1) == 0
				elif weekday == 2 and randi_range(0, 5) == 0:
					events.append(GameEvent.new().wbb(date, wbb_games.pop_front()))
	print("Generated %s events" % len(events))

func make_tutorial_tasks():
	var tut = Task.new()
	tut.title = "My First Task"
	tut.short_desc = "Click me!"
	tut.long_desc = LongStrings.TUT_TASK
	tut.trigger = "_my_first_task"
	
	var bd = Task.new()
	bd.title = "Required Task"
	bd.short_desc = "Hire a Band Director"
	bd.long_desc = LongStrings.HIRE_BD_TASK
	
	tasks.append(tut)
	tasks.append(bd)
	
	for task in tasks:
		task.sticky_texture = load("res://assets/sticky_note.png")
		task.pos = Vector2(595 + (randi() % 250), 80 + (randi() % 250))

func make_tutorial_emails():
	var welc = Email.new()
	welc.summary = "Welcome to Example University"
	welc.from = "Provost Poppy"
	welc.from_email = "poppy_popperson@example.edu"
	welc.text = LongStrings.WELCOME_EMAIL
	welc.datetime = Global.savegame.datetime
	
	var spam1 = Email.new()
	spam1.summary = "10% off Newton Nougat Wafers!"
	spam1.from = "Nougat God"
	spam1.from_email = "noreply@nougat.god"
	spam1.text = LongStrings.NOUGAT_SPAM_EMAIL
	spam1.datetime = (Global.savegame.datetime - Global.SECONDS_IN_DAY)
	
	emails.append(welc)
	emails.append(spam1)

func make_recurring_expenses():
	recurring_expenses.append(load("res://script_resources/expense/band_room_rent.tres"))
	recurring_expenses.append(load("res://script_resources/expense/alumni_fund.tres"))
	recurring_expenses.append(load("res://script_resources/expense/university_budget.tres"))
