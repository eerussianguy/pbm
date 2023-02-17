extends Button

var the_meta = null

func _ready():
	pass # Replace with function body.


func _process(_delta):
	pass


func _on_pressed():
	get_tree().call_group("EmailListener", "_on_email_selected", self, the_meta)
