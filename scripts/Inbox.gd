extends Control

@onready var content = $Panel/Indenter/Content
@onready var sender = $View/Lists/Sender
@onready var summary = $View/Lists/Summary
@onready var time = $View/Lists/Time
@onready var indenter = $Panel/Indenter


var email: Email = null

func _ready():
	_update_view()
	
	sender.get_node("Label").visible = false
	summary.get_node("SumButton").visible = false
	time.get_node("Label").visible = false
	

func _process(_delta):
	indenter.visible = email != null

func _on_emails_updated():
	_update_view()

func _on_email_selected(_button, the_email: Email):
	email = the_email
	_update_view()

func _update_view():
	var sl = sender.get_node("Label")
	var sb = summary.get_node("SumButton")
	var tl = time.get_node("Label")
	
	_delete_not_persistent_children(sender)
	_delete_not_persistent_children(summary)
	_delete_not_persistent_children(time)
	
	for e in Global.savegame.emails:
		var new_sender = sl.duplicate()
		new_sender.visible = true
		new_sender.text = e.from
		sender.add_child(new_sender)
		new_sender.add_to_group("Ephemeral")
		
		var new_time = tl.duplicate()
		new_time.visible = true
		var date = Time.get_date_dict_from_unix_time(e.datetime)
		new_time.text = "%s %s" % [Global.MONTHS[date["month"] - 1].substr(0, 3), date["day"]]
		time.add_child(new_time)
		new_time.add_to_group("Ephemeral")
		
		
		var new_sum = sb.duplicate()
		new_sum.visible = true
		new_sum.text = e.summary
		summary.add_child(new_sum)
		new_sum.add_to_group("Ephemeral")
		new_sum.the_meta = e
	
	if email != null:
		content.get_node("SumLabel").text = email.summary
		content.get_node("Sender/SenderLab").text = email.from
		content.get_node("Sender/EmailLab").text = "<" + email.from_email + ">"
		var date = Time.get_date_dict_from_unix_time(email.datetime)
		content.get_node("DataLabel").text = "to: me\ndate: %s %s, %s" % [Global.MONTHS[date["month"] - 1], date["day"], date["year"]]
		var body = content.get_node("Body")
		body.clear()
		body.append_text(email.text)


func _delete_not_persistent_children(the_node: Node):
	for c in the_node.get_children():
		if c.is_in_group("Ephemeral"):
			c.queue_free()


func _on_delete_btn_pressed():
	if email != null:
		Global.delete_email(email)
		email = null
