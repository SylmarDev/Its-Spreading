extends CharacterBody2D
class_name Enemy

var player
var MAX_HEALTH = 3
var health = MAX_HEALTH
var dead: bool = false

var MAX_SPEED = 60
var ACCEL = 200
var axis: Vector2

var isActive: bool = true
var isActiveTimer: int = 0
var disabledFrames: int = 90

func getMovementDir() -> Vector2:
	return position.direction_to(player.getPosition())

func _ready() -> void:
	print(name)
	pass
	
func _physics_process(delta):
	if (isActive):
		axis = getMovementDir()
		velocity += axis * ACCEL * delta
		velocity = velocity.limit_length(MAX_SPEED)
		
		move_and_slide()
	else:
		isActiveTimer += 1
		if isActiveTimer > disabledFrames:
			isActiveTimer = 0
			isActive = true
	

func hitBy(projectile) -> void:
	health -= projectile.damage
	velocity += (velocity.rotated(3.1415926535) * 1.2)
	if (health <= 0):
		die()
		
func die() -> void:
	if not dead:
		dead = true
		get_parent().playDeathSound(global_position)
		isActive = false
		isActiveTimer = -999
		queue_free()
	
	
