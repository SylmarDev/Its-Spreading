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
	
	var shuffled = global.upgrades.duplicate()
	shuffled.shuffle()
	
	while i < totalUpgradesInShop:
		upgrades[i] = shuffled[i]
		buttons[i].text = "%s\n%s" % [upgrades[i][0], upgrades[i][1]]
		i += 1
	
func buttonPressed(btnNum: int):
	global.playerUpgrades.append(upgrades[btnNum])
	global.upgrades.erase(upgrades[btnNum])
	
	get_tree().change_scene_to_file("res://Scenes/Map.tscn")


func _on_button_0_pressed():
	buttonPressed(0)

func _on_button_1_pressed():
	buttonPressed(1)

func _on_button_2_pressed():
	buttonPressed(2)
