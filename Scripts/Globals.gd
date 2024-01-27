extends Node

var currentStage: int = 0
var paused: bool = true

# divided by 2 seconds sections
var stageTimer: Array = [0, 60, 120, 150]
var rotRate: Array = [3, 3.5, 4, 4.5]
#var stageTimer: Array = [1, 1, 1, 150] # DEBUG

# godot doesn't have structs so its array of strings time
var upgrades: Array

var playerUpgrades: Array
	
func setDefaults() -> void:
	randomize()
	
	currentStage = 0
	
	upgrades = [
		["ArmorPlating", load("res://Art/ArmorPlating.png")],
		["AddtWeaponPort", load("res://Art/AdditionalWeapon.png")],
		["EnhancedThrusters", load("res://Art/EnhancedThrusters.png")],
		["Overclocker", load("res://Art/Overclocker.png")],
		["LuckyPunch", load("res://Art/LuckPunch.png")],
		["SecondChance", load("res://Art/SecondChance.png")],
		["ShieldGenerator", load("res://Art/ShieldGen.png")]
	]
	
	playerUpgrades = []
	
func _process(delta):
	if Input.is_action_just_released("fullscreen"):
		var mode = DisplayServer.WINDOW_MODE_WINDOWED if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN else DisplayServer.WINDOW_MODE_FULLSCREEN
		DisplayServer.window_set_mode(mode)
