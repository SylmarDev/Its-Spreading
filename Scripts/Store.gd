extends Control

var upgrades = []
var totalUpgradesInShop = 3

@onready var buttons = [$VBoxContainer/Button0,
						$VBoxContainer/Button1,
						$VBoxContainer/Button2]

# Called when the node enters the scene tree for the first time.
func _ready():
	upgrades.resize(totalUpgradesInShop)
	var i = 0
	while i < totalUpgradesInShop:
		upgrades[i] = global.upgrades[randi() % len(global.upgrades)-1]
		buttons[i].text = "%s\n%s" % [upgrades[i][0], upgrades[i][1]]
		i += 1
	
func buttonPressed(btnNum: int):
	global.playerUpgrades.append(upgrades[btnNum])
	global.upgrades.erase(upgrades[btnNum])


func _on_button_0_pressed():
	buttonPressed(0)

func _on_button_1_pressed():
	buttonPressed(1)

func _on_button_2_pressed():
	buttonPressed(2)
