extends Node2D
class_name StickyNote

var task: Task

var inside = false
var offset
var dragging = false

func _ready():
	pass # Replace with function body.

func _process(_delta):
	pass

func _physics_process(_delta):
	if Input.is_action_just_pressed("left_click") and inside:
		_on_grabbed()
		offset = get_position() - get_global_mouse_position()
		dragging = true
	if dragging:
		var new_pos = offset + get_global_mouse_position()
		new_pos.x = clamp(new_pos.x, 400, 1100)
		new_pos.y = clamp(new_pos.y, 30, 475)
		set_position(new_pos)
	if not Input.is_action_pressed("left_click"):
		if dragging:
			update_external()
		dragging = false

func _on_grabbed():
	for node in get_tree().get_nodes_in_group("StickyListener"):
		node._on_sticky_clicked(self)

func _on_text_mouse_entered():
	inside = true

func get_task():
	return task

func _on_text_mouse_exited():
	inside = false

func set_info(info):
	$Text.clear()
	$Text.append_text("[center]%s[/center]" % info)

func set_texture_by_name(clr):
	if clr == "yellow":
		set_texture(Global.YELLOW_STICKY)
	elif clr == "blue":
		set_texture(Global.BLUE_STICKY)
	elif clr == "pink":
		set_texture(Global.PINK_STICKY)
	else:
		set_texture(Global.GREEN_STICKY)
	task["color"] = clr
	update_external()

func set_texture(tex):
	$Sprite2D.texture = tex
	task.sticky_texture = tex

func update_external():
	task.pos = Vector2(position.x, position.y)
