extends Node

# VITAL DATA!

var save_name = "save1"

var savegame: SaveGameResource = null

const MONTHS = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
const SECONDS_IN_DAY = 86400
const INT_MAX = 9223372036854775807

const HOLIDAYS = {
	"Halloween": {
		"month": "October",
		"day": 31
	},
	"Christmas": {
		"month": "December",
		"day": 25
	},
	"Christmas Eve": {
		"month": "December",
		"day": 24
	},
	"New Year's Day": {
		"month": "January",
		"day": 1
	}
}

const HOCKEY_TEAMS = {
	"FPU": {
		"name": "Fancy Private University"
	},
	"ORU": {
		"name": "Old Rich University"
	},
	"UVU": {
		"name": "Ultraviolet University"
	},
	"IFU": {
		"name": "Infrared University"
	},
	"FAFT": {
		"name": "Federation of Albertan Fur Traders"
	},
	"USSM": {
		"name": "University South of Southern Maine"
	},
	"SOSU": {
		"name": "Slippery Oil Slick University"
	},
	"SLAC": {
		"name": "Small Liberal Arts College"
	}
}

const BASKETBALL_TEAMS = {
	"FPU": {
		"name": "Fancy Private University"
	},
	"ORU": {
		"name": "Old Rich University"
	},
	"FAFT": {
		"name": "Federation of Albertan Fur Traders"
	},
	"USSM": {
		"name": "University South of Southern Maine"
	},
	"SOSU": {
		"name": "Slippery Oil Slick University"
	},
	"SLAC": {
		"name": "Small Liberal Arts College"
	},
	"ANI": {
		"name": "Army (Northern Ireland)"
	},
	"AW": {
		"name": "Army (Wales)"
	}
}

const TEAMS = {
	"MIH": {
		"name": "Men's Ice Hockey",
		"opps": HOCKEY_TEAMS
	},
	"WIH":{
		"name": "Women's Ice Hockey",
		"opps": HOCKEY_TEAMS
	},
	"MBB": {
		"name": "Men's Basketball",
		"opps": BASKETBALL_TEAMS
	},
	"WBB": {
		"name": "Women's Basketball",
		"opps": BASKETBALL_TEAMS
	}
}


const YELLOW_STICKY = preload("res://assets/sticky_note.png")
const PINK_STICKY = preload("res://assets/pink_sticky_note.png")
const BLUE_STICKY = preload("res://assets/blue_sticky_note.png")
const GREEN_STICKY = preload("res://assets/green_sticky_note.png")

var WEIGHTED_INSTRUMENTS = []

const INSTS = ["alto_saxophone", "baritone", "baritone_saxophone", "clarinet", "drumset", "flute", "keyboard", "mellophone", "tenor_saxophone", "trombone", "trumpet", "tuba"]
const INST_WEIGHTS = [12, 6, 1, 10, 3, 10, 2, 6, 6, 10, 10, 6, ]
var INSTRUMENT_RESOURCES: Dictionary = {}
var INSTRUMENT_ARRAY: Array[Instrument] = []

const BELLA = preload("res://script_resources/songs/bella_ciao.tres")
const CAROL = preload("res://script_resources/songs/carol_of_the_bells.tres")
const FIGHT = preload("res://script_resources/songs/fight_fiercely.tres")
const HAPPY_BIRTHDAY = preload("res://script_resources/songs/happy_birthday.tres")

const SONGS = [BELLA, CAROL, FIGHT, HAPPY_BIRTHDAY]

func _ready():
	print("Global autoload scene initialized")
	
	var idx = 0
	for inst in INSTS:
		var resource = Instrument.new()
		resource.create(inst, inst.capitalize(), INST_WEIGHTS[idx])
		idx += 1
		INSTRUMENT_RESOURCES[inst] = resource
		INSTRUMENT_ARRAY.append(resource)
		for i in range(0, resource.weight):
			WEIGHTED_INSTRUMENTS.append(inst)
	
func set_roster(input):
	Global.savegame.roster = input
	get_tree().call_group("RosterListener", "_on_roster_updated")
	
func set_events(input):
	Global.savegame.events = input
	get_tree().call_group("EventListener", "_on_events_updated")

func set_datetime(input):
	Global.savegame.datetime = input
	_delete_old_transactions(input)	
	get_tree().call_group("DateListener", "_on_date_updated")

func set_tasks(input):
	Global.savegame.tasks = input
	get_tree().call_group("TaskListener", "_on_tasks_updated")

func set_emails(input):
	Global.savegame.emails = input
	get_tree().call_group("EmailListener", "_on_emails_updated")

func add_email(new_email):
	Global.savegame.emails.append(new_email)
	get_tree().call_group("EmailListener", "_on_emails_updated")

func delete_email(email):
	Global.savegame.emails.erase(email)
	Global.savegame.old_emails.append(email)
	get_tree().call_group("EmailListener", "_on_emails_updated")

func set_recurring_expenses(expenses):
	Global.savegame.recurring_expenses = expenses
	get_tree().call_group("MoneyListener", "_on_money_updated")

# todo
func take_money(amount, info) -> bool:
	if amount > Global.savegame.cash:
		return false
	Global.savegame.cash -= amount
	
	info.amount = -1 * amount
	info.date = Global.savegame.datetime
	Global.savegame.transactions.append(info)
	get_tree().call_group("MoneyListener", "_on_money_updated")
	return true

# todo
func give_money(amount, info):
	Global.savegame.cash += amount
	
	info.amount = amount
	info.date = Global.savegame.datetime
	Global.savegame.transactions.append(info)
	get_tree().call_group("MoneyListener", "_on_money_updated")

func _delete_old_transactions(new_time):
	var updated = false
	var month = Time.get_date_dict_from_unix_time(new_time)["month"]
	var new_transactions = []
	for transaction in Global.savegame.transactions:
		if month == Time.get_date_dict_from_unix_time(transaction.date)["month"]:
			new_transactions.append(transaction)
		else:
			updated = true
	if updated:
		Global.savegame.transactions = new_transactions
		get_tree().call_group("MoneyListener", "_on_money_updated")

func add_task(new_task):
	Global.savegame.tasks.append(new_task)
	get_tree().call_group("TaskListener", "_on_tasks_updated")


func complete_task_trigger(trigger):
	var to_remove = null
	for task in Global.savegame.tasks:
		if task.trigger == trigger:
			to_remove = task
	if to_remove != null:
		Global.savegame.tasks.erase(to_remove)
		Global.savegame.old_tasks.append(to_remove)
		set_tasks(Global.savegame.tasks)

func current_day_of_week():
	return day_of_week(Global.savegame.datetime)
	
func day_of_week(ticks):
	return (floor(int(ticks) / SECONDS_IN_DAY) + 4) % 7

func get_tomorrow_skip():
	var tmrw = Global.savegame.datetime + SECONDS_IN_DAY
	for event in Global.savegame.events:
		if event["date"] == Global.savegame.datetime:
			return Global.savegame.datetime
	return tmrw 

func advance_day():
	var day = get_tomorrow_skip()
	if day > savegame.datetime:
		set_datetime(day)
		do_daily_decay()
	return day

func do_daily_decay():
	for mem in savegame.roster:
		mem.add_exhaustion(-2)
		if mem.happiness > 50:
			mem.add_happiness(-1)
		elif mem.happiness < 50:
			mem.add_happiness(1)
	set_roster(savegame.roster)

func get_skip_to_day():
	var min_dat = INT_MAX
	for event in Global.savegame.events:
		var dat = event.date
		if dat >= Global.savegame.datetime and dat < min_dat:
			min_dat = dat
	if min_dat == INT_MAX:
		return Global.savegame.datetime
	return min_dat

func advance_to_next_event():
	var day = get_skip_to_day()
	if day > Global.savegame.datetime:
		set_datetime(day)
	return day
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func random_instrument():
	var inst = random_from(WEIGHTED_INSTRUMENTS)
	return INSTRUMENT_RESOURCES[inst]

func random_from(seq):
	return seq[randi() % seq.size()]
