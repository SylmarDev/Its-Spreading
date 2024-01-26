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

var luckyPunch: bool = global.playerUpgrades.any(func(n): return n[0] == "LuckyPunch")
var luckyPunchChance = 7.5

func getMovementDir() -> Vector2:
	if player != null:
		return position.direction_to(player.getPosition())
	return Vector2(0, 0)
	
func _ready() -> void:
	$AnimatedSprite2D.play("walk")
	
func _physics_process(delta):
	if (isActive):
		axis = getMovementDir()
		velocity += axis * ACCEL * delta
		velocity = velocity.limit_length(MAX_SPEED)
		
		move_and_slide()
		$AnimatedSprite2D.flip_h = axis.x < 0
	else:
		isActiveTimer += 1
		if isActiveTimer > disabledFrames:
			isActiveTimer = 0
			isActive = true
	

func hitBy(projectile) -> void:
	health -= projectile.damage
	velocity += (velocity.rotated(3.1415926535) * 1.2)
	if (health <= 0 or (luckyPunch and randf_range(0, 100) < luckyPunchChance)):
		die()
		
func die() -> void:
	if not dead:
		dead = true
		get_parent().createDeathParticleEffect(global_position)
		get_parent().playDeathSound(global_position)
		isActive = false
		isActiveTimer = -999
		queue_free()
