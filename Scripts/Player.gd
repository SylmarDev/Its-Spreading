extends CharacterBody2D

@onready var coll = $CollisionShape2D
@onready var hearing = $Hearing
@onready var gun = $ShipGun
var gun2 = null

var gunScene = preload("res://Scenes/ShipGun.tscn")

var MAX_SPEED = 100 # 100 originally
var ACCEL = 375
var friction = 150 # 150 originally

var motion: Vector2
var axis: Vector2
var prevAngle: float

var shipAngleTo: float = 0.0
var turnSpeed: float = 0.05 # float between 0 and 1 iirc

var MAX_HEALTH = 100.0
var health = 100.0

var healthbar

var oneGunLocation = Vector2(0, 3)
var twoGunLocations = [Vector2(-8, 1), Vector2(8, 1)]

# ITEMS
var secondChance: bool = false
var shieldGenerator: bool = false

var invincible: bool = false
var invincibleCounter: int = 180

func _ready() -> void:
	# set upgrades if applicable
	for upgrade in global.playerUpgrades:
		match upgrade[0]: # upgrade[0] is the string of the upgrade name
			"ArmorPlating":
				MAX_HEALTH = 200
				health = MAX_HEALTH
			"AddtWeaponPort":
				gun2 = gunScene.instantiate()
				gun2.startPos = twoGunLocations[1]
				gun2.defaultGunCooldown = gun.defaultGunCooldown
				add_child(gun2)
			"EnchanedThrusters":
				MAX_SPEED = 200
				ACCEL = 300
				friction = 200
			"Overclocker":
				# TODO: make work with addt weapon
				gun.defaultGunCooldown /= 2
				if gun2 != null:
					gun2.defaultGunCooldown = gun.defaultGunCooldown
			"SecondChance":
				secondChance = true
			"ShieldGenerator":
				shieldGenerator = true
			_:
				print("upgrade %s not found!" % upgrade[0])
				
	# set weapon positions
	var hasAdditionalWeaponPort = global.playerUpgrades.any(func(n): return n[0] == "AddtWeaponPort")
	gun.startPos = twoGunLocations[0] if hasAdditionalWeaponPort else oneGunLocation

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
	
	if invincible:
		invincibleCounter -= 1
		invincible = invincibleCounter >= 0
		
	move_and_slide()
	
	for index in get_slide_collision_count():
		var coll = get_slide_collision(index).get_collider()
		if (coll.get_parent().name == "Enemies" && coll.isActive):
			coll.isActive = false
			hurt(5)
	
func get_input():
	var axis = Vector2.ZERO
	axis = Input.get_vector("left", "right", "up", "down")
	
	return axis
	
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

func rotCount() -> int:
	var rotCount = 0
	for area in hearing.get_overlapping_areas():
		if (area.has_method("isRot")):
			rotCount += 1
	return rotCount
	
func getPosition() -> Vector2:
	return global_position

func getHealth() -> float:
	return health

func hurt(damage: float) -> void:
	if shieldGenerator or invincible:
		# TODO: shield gen sfx
		shieldGenerator = false
		return
	
	health -= damage
	# update healthbar
	if healthbar == null:
		healthbar = get_node("../CanvasLayer/ProgressBar")
		healthbar.max_value = MAX_HEALTH
		
	healthbar.value = health
	if health <= 0:
		die()
	
	
func die() -> void:
	if (secondChance):
		secondChance = false
		invincible = true
		return
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
	
func isInvincible() -> bool:
	return invincible
	
	
	
	
	
