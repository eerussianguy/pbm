extends Control


func _ready():
	pass # Replace with function body.


func _process(_delta):
	pass


func _on_new_game_btn_pressed():
	var creator = load("res://scenes/game_creator.tscn").instantiate()
	add_child(creator)

func _on_load_game_btn_pressed():
	var new_name = "save1"
	if FileAccess.file_exists("user://%s.json" % Global.save_name):
		var instance = load("res://scenes/game_instance.tscn").instantiate()
		Global.save_name = new_name
		
		instance.read()
		get_tree().change_scene_to_file("res://scenes/root.tscn")
		get_tree().get_root().add_child(instance)
	else:
		print("Error occurred trying to access save named: %s" % new_name)


func _on_quit_game_btn_pressed():
	get_tree().quit()

func _on_options_btn_pressed():   
	var inst = load("res://scenes/options.tscn").instantiate()
	add_child(inst)
