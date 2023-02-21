extends Control

var persistent_sort_id = 0
var selected = null

func _ready():
	var sort_popup = get_node("HBoxContainer/SortButton").get_popup()
	sort_popup.connect("index_pressed", self._on_sort_pressed)

func _process(_delta):
	pass

func _on_roster_updated():
	_on_sort_pressed(persistent_sort_id)

func get_roster():
	return Global.savegame.roster

func short_description(member) -> String:
	var result = "%s %s (%s)" % [member.first_name, member.last_name, parse_year(member.year, member.grad_student)]
	if member.is_section_leader():
		result += " (SL)"
	return result

func parse_year(year, grad_student) -> String:
	match year:
		1:
			return "1st Year Grad" if grad_student else "Freshman"
		2:
			return "2nd Year Grad" if grad_student else "Sophomore"
		3:
			return "Junior"
		4:
			return "Senior"
		5:
			return "Super Senior"
	return "Super Super Senior"

func _on_roster_list_item_selected(index):
	var mem = get_node("RosterList").get_item_metadata(index)
	selected = mem
	var is_section_leader = mem.is_section_leader()
	var info = get_node("MemberPanel/MemberInfo")
	
	var name_lab = get_node("MemberPanel/MemberName")
	name_lab.text = "%s %s" % [mem.first_name, mem.last_name]
	
	info.clear()
	info.append_text("Primary Instrument: %s" % mem.instrument.name)
	info.newline()	
	info.append_text("Gender: %s" % str(mem.get_gender_value()))
	info.newline()
	info.append_text("Year: %s" % parse_year(mem.year, mem.grad_student))
	if is_section_leader:
		info.newline()
		info.append_text("Section Leader")
	info.newline()
	info.append_text("Happiness: %s Exhaustion: %s" % [mem.happiness, mem.exhaustion])
	
	var skills = get_node("MemberPanel/SkillBox")
	skills.get_node("TechnicalSkill").set_progress(mem.technical)
	skills.get_node("IntonationSkill").set_progress(mem.intonation)
	skills.get_node("LeadershipSkill").set_progress(mem.leadership)
	skills.get_node("SocialSkill").set_progress(mem.social)
	get_node("MemberPanel/SkillOverall").text = "Overall: %s" % mem.calculate_ovr()
	
	$MemberPanel/Buttons/MakeLeaderBtn.disabled = is_section_leader
	
	var car = get_node("MemberPanel/Career")
	car.clear()
	for cdat in mem.career:
		var car_inf
		if cdat["gigs"] == 0:
			car_inf = "Year: %s (Did not play)" % [parse_year(cdat["year"], cdat["grad_student"])]
		else:
			car_inf = "Year: %s Gigs: %s Inst: %s" % [parse_year(cdat["year"], cdat["grad_student"]), cdat["gigs"], cdat["instrument"]]
		car.add_item(car_inf, null, false)



func _on_sort_pressed(index):
	persistent_sort_id = index
	var display_roster = get_roster().duplicate()
	if index == 1: # alphabetical first
		display_roster.sort_custom(sort_az_first)
	elif index == 2: # instrument
		display_roster.sort_custom(sort_az_inst)
	elif index == 3: # class year
		display_roster.sort_custom(sort_year)
	elif index == 4: # ovr skill
		display_roster.sort_custom(sort_ovr_skill)
	else: # default or 1, alphabetical last
		display_roster.sort_custom(sort_az_last)
	var id = 0
	var list = get_node("RosterList")
	list.clear()
	var select_id = 0
	for member in display_roster:
		var texture = member.instrument.texture
		list.add_item(short_description(member), texture, true)
		list.set_item_metadata(id, member)
		list.set_icon_scale(0.5)
		if selected != null and selected == member:
			select_id = id
		id += 1
	list.select(select_id, true)
	_on_roster_list_item_selected(select_id)

	return get_node("RosterList")		

func sort_az_inst(mem1, mem2):
	var first = mem1.instrument.name
	var second = mem2.instrument.name
	if first == second:
		return sort_year(mem1, mem2)
	else:
		return first > second

func sort_az_first(mem1, mem2):
	return alphab(mem1.first_name, mem2.last_name)

func sort_az_last(mem1, mem2):
	return alphab(mem1.last_name, mem2.last_name)

func sort_year(mem1, mem2):
	var year1 = mem1.year
	var year2 = mem2.year
	if mem1.grad_student:
		year1 += 6
	if mem2.grad_student:
		year2 += 6
	return year1 < year2

func sort_ovr_skill(mem1, mem2):
	return mem1.calculate_ovr() < mem2.calculate_ovr()

func alphab(string1, string2):
	for i in range(0, 4):	
		var comp = compare_index(string1, string2, i)
		if comp != 0:
			if comp == -1:
				return true
			else:
				return false
	return true

func compare_index(string1, string2, index):
	return string1.substr(index, 1).naturalnocasecmp_to(string2.substr(index, 1))


func _on_make_leader_btn_pressed():
	if selected != null:
		Global.savegame.section_leaders[selected.instrument.name] = selected
		Global.set_roster(Global.savegame.roster)
