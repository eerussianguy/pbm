extends Control
class_name InfoPopup

var expiring = false
var accumulated = 0
var sim: Event = null


func _ready():
	if sim == null:
		var btn = $Panel/VBox/Btns/SimBtn
		btn.visible = false
		btn.disabled = true


func _process(delta):
	if expiring:
		accumulated += delta
		if accumulated > 3:
			queue_free()

func _unhandled_input(_event):
	if Input.is_action_pressed("ui_cancel"):
		queue_free()

func _set_popup_text(text):
	var info = $Panel/VBox/RichTextLabel
	info.clear()
	info.append_text(text)

func _set_popup_title(text):
	var info = $Panel/VBox/Label
	info.text = text

func _set_expiring():
	expiring = true

func _set_simulation(simulation):
	sim = simulation
	var btn = $Panel/VBox/Btns/SimBtn
	btn.visible = true
	btn.disabled = false

func _on_ok_btn_pressed():
	queue_free()

func _on_sim_btn_pressed():
	if sim != null:
		if sim is RehearsalEvent:
			var event = load("res://scenes/rehearsal_sim.tscn").instantiate()
			event.event = sim
			get_parent().add_child(event)
		elif sim is GameEvent:
			if sim.team == "MIH" or sim.team == "WIH":
				var event = load("res://scenes/hockey_sim.tscn").instantiate()
				event.event = sim
				get_parent().add_child(event)
		
		queue_free()
