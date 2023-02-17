extends Control


func _ready():
	print("Game instance entered scene tree")
	_update_view()

func _reset_global_variables():
	print("Resetting game")
	
	Global.savegame = SaveGameResource.new()
	Global.savegame.init_fresh_game()
	
	save()

func _update_view():
	Global.set_datetime(Global.savegame.datetime)
	Global.set_roster(Global.savegame.roster)
	Global.set_events(Global.savegame.events)
	Global.set_tasks(Global.savegame.tasks)
	Global.set_emails(Global.savegame.emails)
	Global.set_recurring_expenses(Global.savegame.recurring_expenses)

func _process(_delta):
	pass

func read():
	var savegame = load("user://%s.tres" % Global.save_name)
	print("Successfully loaded savegame as resource")
	Global.savegame = savegame

func save():
	if Global.savegame == null:
		print("Savegame null!")
	else:
		print("Saving game as resource")
		ResourceSaver.save(Global.savegame, "user://%s.tres" % Global.save_name)
	
func _on_save_btn_pressed():
	save()
	var popup = load("res://scenes/info_popup.tscn").instantiate()
	popup._set_popup_text("[center]Game saved.[/center]")
	popup._set_expiring()
	add_child(popup)

func _on_menu_button_pressed():
	save()
	var instance = load("res://scenes/main_menu.tscn")
	get_tree().change_scene_to_packed(instance)
