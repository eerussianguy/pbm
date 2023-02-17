extends Control


func _ready():
	pass # Replace with function body.


func _process(_delta):
	pass


func _on_start_btn_pressed():
	Global.save_name = "save1"
	var instance = load("res://scenes/game_instance.tscn").instantiate()
	instance._reset_global_variables()
	get_tree().change_scene_to_file("res://scenes/root.tscn")
	get_tree().get_root().add_child(instance)


func _on_cancel_btn_pressed():
	queue_free()

func _unhandled_input(_event):
	if Input.is_action_pressed("ui_cancel"):
		queue_free()


func _on_bs_slider_value_changed(value):
	$Panel/VBoxContainer/BandSizeContainer/ResultLabel.text = var_to_str(int(value))


func _on_save_name_edit_text_changed(new_text):
	var edit = $Panel/VBoxContainer/SaveNameContainer/SaveNameEdit
	var start = $Panel/VBoxContainer/HBoxContainer2/StartBtn
	start.disabled = len(new_text) == 0
