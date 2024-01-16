extends Sprite2D

var rng = RandomNumberGenerator.new()

var gunReady = true
var gunCooldown = 30

var spread = 0.07
var bullet = preload("res://Scenes/Bullet.tscn")

var kickback: float = 0.0 # pixels of kickback, must always be less than cooldown
var kickbackBase = 6
var kickbackVariation = 1

var shotAngle: float # last shot angle

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# shoot a bullet
func shootBullet():
	gunReady = false
	gunCooldown = 30
	
	shotAngle = rotation + rng.randf_range(-spread, spread) # in rads
	
	var bullet_instance = bullet.instantiate()
	bullet_instance.rotation = shotAngle
	bullet_instance.global_position = $Marker2D.global_position
	
	add_child(bullet_instance)
	
	# kickback
	kickback = kickbackBase + rng.randf_range(-kickbackVariation, kickbackVariation)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# face mouse
	look_at(get_global_mouse_position())
	if (Input.is_action_pressed("mb_left") and gunReady):
		shootBullet()
		
	if (kickback > 0):
		kickback = lerp(kickback, 0.0, 0.3)
		position.x -= kickback * cos(shotAngle)
		position.y -= kickback * -sin(shotAngle)
		#print(kickback)
		if kickback < 0.25:
			kickback = 0
		
	if not gunReady:
		gunCooldown -= 1
		gunReady = gunCooldown == 0
