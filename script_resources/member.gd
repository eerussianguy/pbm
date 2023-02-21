extends Resource
class_name Member

enum Gender {Male, Female, Nonbinary}

var DEFAULT_INST: Instrument = Global.INSTRUMENT_RESOURCES["flute"]

@export var first_name: String = "First"
@export var last_name: String = "Last"
@export var gender: Gender = Gender.Male
@export var year: int = 1
@export var grad_student: bool = false
@export var instrument: Instrument = DEFAULT_INST
@export var intonation: int = 1
@export var technical: int = 1
@export var leadership: int = 1
@export var social: int = 1
@export var career: Array = []
@export var traits: Array = []
@export var happiness = 50
@export var exhaustion = 0


func new_member(male, female, last, index):
	var gender_random = randi() % 101
	if gender_random < 49:
		gender = Gender.Male
		first_name = self.random_from(male)
	elif gender_random < 99:
		gender = Gender.Female
		first_name = random_from(female)
	else:
		gender = Gender.Nonbinary
		if randi_range(0, 1) == 0:
			first_name = random_from(male)
		else:
			first_name = random_from(female)
	last_name = random_from(last)
	if randi() % 30 == 0:
		last_name += "-" + random_from(last)
	if randi() % 100 == 0:
		last_name += " Jr."
	elif randi() % 100 == 0:
		last_name += " III"
	year = randi_range(1, 4)
	if randi() % 20 == 0:
		year = 5
	elif randi() % 20 == 0:
		year = 6
	grad_student = randi() % 12 == 0 and year < 3
	instrument = random_from(Global.INSTRUMENT_ARRAY) if index != 0 else Global.INSTRUMENT_RESOURCES["drumset"]

	technical = weight_skill(year, grad_student)
	intonation = weight_skill(year, grad_student)
	leadership = weight_skill(year, grad_student)
	social = weight_skill(year, grad_student)
	
	if leadership > 30 and technical > 60 and intonation > 60 and randi() % 5 == 0:
		traits.append("proud")
	if randi() % 11 == 0:
		traits.append("workaholic")
	
	for i in range(1, year):
		var gigs = randi_range(24, 36)
		if randi() % 20 == 0:
			gigs = randi_range(2, 10)
		if randi() % 16 == 0:
			if len(career) > 0:
				gigs = 0
			else:
				continue
		career.append({
			'year': i,
			'grad_student': grad_student,
			'gigs': gigs,
			'instrument': instrument.name
		})

func add_happiness(amount):
	happiness = clampi(happiness + amount, 0, 100)

func add_exhaustion(amount):
	exhaustion = clampi(exhaustion + amount, 0, 100)

func weight_skill(years: int, grad: bool):
	if grad:
		years += 4
	if years < 4 and randi() % 20 == 0:
		years = 4
	var weighted = clampi(years + randi_range(-1, 1), 1, 5) / 5.0
	return int(weighted * randi_range(10, 90) + 10)

func random_from(seq):
	return seq[randi() % seq.size()]

func get_gender_value():
	return Gender.keys()[gender]

func calculate_ovr():
	var avg = (technical + intonation + leadership + social) / 4.0
	avg *= 1.1 # forgiveness
	return clampi(int(avg), 1, 99)
	
func is_section_leader():
	return Global.savegame.section_leaders[instrument.name] == self
