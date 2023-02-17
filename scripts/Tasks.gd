extends Control

var focused = null

func _ready():
	_update_view()

func _process(_delta):
	if visible:
		$Panel/VBoxContainer.visible = focused != null
		$Panel/NoneSelected.visible = focused == null
		$Panel/VBoxContainer/CompleteBtn.visible = focused != null and focused.task.trigger != "null"
	else:
		focused = null

func _on_tasks_updated():
	_update_view()
	focused = null

func _update_view():
	for sticky in get_tree().get_nodes_in_group("Sticky"):
		sticky.queue_free()
	for task in Global.savegame.tasks:
		var stick = load("res://scenes/sticky_note.tscn").instantiate()
		stick.set_info(task.short_desc)
		stick.position = task.pos
		stick.task = task
		stick.set_texture(task.sticky_texture)
		add_child(stick)

func _on_sticky_clicked(node):
	focused = node
	var task = node.task
	var title = $Panel/VBoxContainer/Title
	title.text = task.title
	var short_lab = $Panel/VBoxContainer/ShortLabel
	short_lab.clear()
	short_lab.append_text(task.short_desc)
	var long_lab = $Panel/VBoxContainer/LongLabel
	long_lab.clear()
	long_lab.append_text(task.long_desc)

func _on_y_btn_pressed():
	if focused != null:
		focused.set_texture(Global.YELLOW_STICKY)

func _on_p_btn_pressed():
	if focused != null:
		focused.set_texture(Global.PINK_STICKY)

func _on_g_btn_pressed():
	if focused != null:
		focused.set_texture(Global.GREEN_STICKY)

func _on_b_btn_pressed():
	if focused != null:
		focused.set_texture(Global.BLUE_STICKY)

func _on_complete_btn_pressed():
	if focused != null and focused.task.trigger != "null":
		call(focused.task.trigger, focused, focused.task)

# Here is where the task-specific completion functions live
# They are called via reflection when a task with a specified 'trigger' string is completed.
# The string is the name of the function being called.

func _my_first_task(_node, task):
	Global.complete_task_trigger(task["trigger"])
	_simple_popup("Congratulations! You finished your first task. It will be removed from your board.")

func _simple_popup(text: String):
	var popup = load("res://scenes/info_popup.tscn").instantiate()
	popup._set_popup_text("[center]%s[/center]" % text)
	add_child(popup)
