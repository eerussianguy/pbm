extends Resource
class_name Task

const DEFAULT_TEX = preload("res://assets/sticky_note.png")

@export var title: String = "Title"
@export var short_desc: String = "short desc"
@export var long_desc: String = "long desc"
@export var trigger: String = "null"
@export var sticky_texture: Texture2D = DEFAULT_TEX
@export var pos: Vector2 = Vector2.ZERO

