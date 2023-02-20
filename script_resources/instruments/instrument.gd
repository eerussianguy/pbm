extends Resource
class_name Instrument

@export var short_name = "my_inst"
@export var name: String = "MyInstrument"
@export var weight: int = 10
@export var texture: Texture2D = preload("res://assets/alto_saxophone.png")


func create(short_name_in: String, long_name: String, weight_in: int = 10):
	short_name = short_name_in
	name = long_name
	weight = weight_in
	texture = load("res://assets/%s.png" % short_name)
