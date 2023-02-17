extends Resource
class_name Task

@export var title: String
@export var short_desc: String
@export var long_desc: String
@export var trigger: String
@export var sticky_texture: Texture2D
@export var pos: Vector2

const DEFAULT_TEX = preload("res://assets/sticky_note.png")

func _init(p_title = "Title", p_short_desc = "Short", p_long_desc = "Long", p_trigger = "null", p_sticky_texture = DEFAULT_TEX, p_pos = Vector2.ZERO):
	title = p_title
	short_desc = p_short_desc
	long_desc = p_long_desc
	trigger = p_trigger
	sticky_texture = p_sticky_texture
	pos = p_pos

