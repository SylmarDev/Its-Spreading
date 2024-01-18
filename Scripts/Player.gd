extends CharacterBody2D

@onready var coll = $CollisionShape2D

var MAX_SPEED = 100
var ACCEL = 375
var friction = 150

var motion: Vector2
var axis: Vector2
var prevAngle: float

var shipAngleTo: float = 0.0
var turnSpeed: float = 0.05 # float between 0 and 1 iirc

func _physics_process(delta):
	axis = get_input()
	if axis == Vector2.ZERO:
		if velocity.length() > (friction * delta):
			rotateShip()
			velocity -= velocity.normalized() * (friction * delta)
		else:
			velocity = Vector2.ZERO
	else:
		# ship rotation
		setShipAngleTo(axis)
		rotateShip()
		
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
	
func setShipAngleTo(v: Vector2) -> void:
	shipAngleTo = rad_to_deg(v.angle()) + 90
	
# this might need more touch ups but for now its very good
# this is as good as I'm going to get it
func rotateShip() -> void:
	var currentRotation = normalizeAngle(rotation_degrees)
	var destRotation = normalizeAngle(shipAngleTo)
	
	if abs(currentRotation - destRotation) > abs((currentRotation + 360) - destRotation):
		destRotation -= 360.0
	elif abs(currentRotation - destRotation) > abs(currentRotation - (destRotation + 360)):
		destRotation += 360.0
	
	rotation_degrees = (lerp(currentRotation, destRotation, turnSpeed))

func normalizeAngle(a: float) -> float:
	while a < 0: # is negative
		a += 360
	
	return fmod(a, 360.0)
