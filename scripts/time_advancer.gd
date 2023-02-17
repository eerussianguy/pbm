extends Control


func _ready():
	_on_date_updated()

func _on_date_updated():
	$Panel/VBoxContainer/OneDayBtn.disabled = Global.get_tomorrow_skip() == Global.savegame.datetime
	$Panel/VBoxContainer/NextEventBtn.disabled = Global.get_skip_to_day() == Global.savegame.datetime

func _process(_delta):
	pass

func _on_one_day_btn_pressed():
	Global.advance_day()
	var popup = load("res://scenes/info_popup.tscn").instantiate()
	popup._set_popup_text("Successfully advanced one day.")
	get_tree().current_scene.add_child(popup)
	queue_free()

func _on_next_event_btn_pressed():
	var old = Global.savegame.datetime
	var day = Global.advance_to_next_event()
	var popup = load("res://scenes/info_popup.tscn").instantiate()
	popup._set_popup_text("Successfully advanced %s day(s)." % [(day - old) / Global.SECONDS_IN_DAY])
	get_tree().current_scene.add_child(popup)
	queue_free()

func _unhandled_input(_event):
	if Input.is_action_pressed("ui_cancel"):
		queue_free()

func _on_cancel_btn_pressed():
	queue_free()
