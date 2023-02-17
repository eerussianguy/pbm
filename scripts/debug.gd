extends Control

func _ready():
	_refresh()

func _process(delta):
	if visible:
		$VBoxContainer/FPSLabel.text = "FPS: " + str(int(1 / delta))

func _on_refresh_btn_pressed():
	_refresh()


func _on_dump_btn_pressed():
	$Text.clear()
	
	$Text.append_text("Unused")

func _refresh():
	var txt = $Text
	txt.clear()
	txt.append_text("Events: %s" % (len(Global.savegame.events)))
	txt.newline()
	txt.append_text("Tasks: %s" % (len(Global.savegame.tasks)))
	txt.newline()
	txt.append_text("Members: %s" % (len(Global.savegame.roster)))
	txt.newline()
	txt.append_text("Datetime: %s" % Global.savegame.datetime)
	txt.newline()
	txt.append_text("Expanded Datetime: %s" % Time.get_date_dict_from_unix_time(Global.savegame.datetime))
	txt.newline()
	txt.append_text("Save Name: %s" % Global.save_name)
	
