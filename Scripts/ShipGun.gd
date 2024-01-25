extends Node2D

var rng = RandomNumberGenerator.new()

var gunReady = true
var defaultGunCooldown = 30
var gunCooldown = defaultGunCooldown

var spread = 0.07
@onready var bullet = preload("res://Scenes/Bullet.tscn")

var shotAngle: float # last shot angle

@export var startPos: Vector2

@onready var audioStreamPlayer = $AudioStreamPlayer2D

# Called when the node enters the scene tree for the first time.
func _ready():
	top_level = true
	z_index = 2
	

# shoot a bullet
func shootBullet():
	gunReady = false
	gunCooldown = defaultGunCooldown
	
	shotAngle = rotation + rng.randf_range(-spread, spread) # in rads
	
	var bullet_instance = bullet.instantiate()
	bullet_instance.rotation = shotAngle
	# TODO: marker2d pos not always at tip of gun
	bullet_instance.global_position = $GunSpr/Marker2D.global_position
	bullet_instance.thingsIHit = [Rot, Enemy, RotTileMap]
	
	audioStreamPlayer.playing = true
	
	add_child(bullet_instance)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position = get_parent().position + startPos.rotated(get_parent().rotation)
	look_at(get_global_mouse_position())
	if (Input.is_action_pressed("mb_left") and gunReady):
		shootBullet()
		
	if not gunReady:
		gunCooldown -= 1
		gunReady = gunCooldown == 0
