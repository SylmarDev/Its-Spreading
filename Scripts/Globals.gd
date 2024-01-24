extends Node

var currentStage: int = 0

# divided by 2 seconds
#var stageTimer: Array = [60, 70, 90, 120, 150, 180]
var stageTimer: Array = [2, 4, 6, 8, 150, 180] # DEBUG

# godot doesn't have structs so its array of strings time
var upgrades: Array = [
	["ArmorPlating", "Grants additional health to the Ship"],
	["AddtWeaponPort", "Grants an additional weapon"],
	["EnchanedThrusters", "Increases base movement speed of the Ship"],
	["Overclocker", "Increases rate of fire of weapons"], 
	["LuckyPunch", "Chance to insta-kill enemies"], 
	["SecondChance", "If the ship is destroyed, survive on 1 HP"],
	["ShieldGenerator", "Negate the first damage taken"]
]

var playerUpgrades: Array = []
