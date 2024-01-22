extends Area2D
class_name Rot

@onready var shape = $CollisionShape2D
var parent # RotMap

# relates to rotmap coords
var mapX: int
var mapY: int

# Called when the node enters the scene tree for the first time.
func _ready():
	#var dim = [shape.shape.size[0], shape.shape.size[1]]
	parent = get_parent()
	#print("x: %s  y:%s" % [str(mapX), str(mapY)]) # DEBUG

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func hitBy(object):
	parent.deleteRotAtCoords(mapX, mapY)
	queue_free()
