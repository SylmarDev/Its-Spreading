extends Node

var currentStage: int = 0

# divided by 2 seconds sections
var stageTimer: Array = [60, 90, 120, 150] 
#var stageTimer: Array = [1, 1, 1, 150] # DEBUG

# godot doesn't have structs so its array of strings time
var upgrades: Array

var playerUpgrades: Array
	
func setDefaults() -> void:
	randomize()
	
	currentStage = 0
	
	upgrades = [
		["ArmorPlating", "Grants additional health to the Ship"],
		["AddtWeaponPort", "Grants an additional weapon"],
		["EnhancedThrusters", "Increases base movement speed of the Ship"],
		["Overclocker", "Increases rate of fire of weapons"], 
		["LuckyPunch", "Chance to insta-kill enemies"], 
		["SecondChance", "If the ship is destroyed, survive on 1 HP"],
		["ShieldGenerator", "Negate the first damage taken"]
	]
	
	playerUpgrades = []
