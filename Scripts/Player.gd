extends CharacterBody2D

@onready var coll = $CollisionShape2D

var MAX_SPEED = 100
var ACCEL = 375
var friction = 150

var motion: Vector2
var axis: Vector2
var prevAngle: float

func _physics_process(delta):
	axis = get_input()
	if axis == Vector2.ZERO:
		if velocity.length() > (friction * delta):
			velocity -= velocity.normalized() * (friction * delta)
		else:
			velocity = Vector2.ZERO
	else:
		velocity += axis * ACCEL * delta
		velocity = velocity.limit_length(MAX_SPEED)
	
	move_and_slide()
	#look_at(get_global_mouse_position())
	
func get_input():
	var axis = Vector2.ZERO
	
	if Input.is_action_pressed("down"):
		axis.y += 1
	if Input.is_action_pressed("up"):
		axis.y -= 1
	if Input.is_action_pressed("right"):
		axis.x += 1
	if Input.is_action_pressed("left"):
		axis.x -= 1
	
	return axis.normalized()
	
