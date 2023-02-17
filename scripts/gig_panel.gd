extends Control

@export var metadata: Event

func _ready():
	pass # Replace with function body.

func _process(_delta):
	pass

func _on_button_pressed():
	if len(get_tree().get_nodes_in_group("Popup")) == 0:
		
		var popup: InfoPopup = load("res://scenes/info_popup.tscn").instantiate()
		var dt = Time.get_date_dict_from_unix_time(metadata.date)
		var datestring = "%s %s, %s @ %s" % [dt["day"], Global.MONTHS[dt["month"]-1], dt["year"], metadata.time]
		if metadata.date == Global.savegame.datetime:
			popup._set_simulation(metadata)
		if metadata is GameEvent:
			var team_data = Global.TEAMS[metadata.team]
			var team = team_data["name"]
			var vs = team_data["opps"][metadata.vs]["name"]
			popup._set_popup_text("Team: %s\nOpponent: %s\nLocation: %s\nDate: %s" % [team, vs, metadata.location, datestring])
		elif metadata is RehearsalEvent:
			popup._set_popup_text("Songs to Rehearse:\n%s\n%s\n%s" % [metadata.songs_to_rehearse[0].title, metadata.songs_to_rehearse[1].title, metadata.songs_to_rehearse[2].title])
		
		get_tree().current_scene.add_child(popup)
