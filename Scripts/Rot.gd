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

func hitBy(object):
	parent.deleteRotAtCoords(mapX, mapY)
	queue_free()

func isRot() -> bool:
	return true

func _on_body_entered(body):
	if body.name == "Player":
		body.hurt(5) # 2 for now
