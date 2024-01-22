extends Node2D
class_name RotMap
# this class will handle all the spreading logic that way its only in one place

var playableArea: Vector2 # Vector2 of playing area
var rotTilesPositions: Array
var rotTiles: Array
var rotDiff: Vector2 # amt the center is off

@onready var rot = preload("res://Scenes/Rot.tscn")
var rotDim: Vector2 = Vector2(4, 4) # hardcoded for now sue me (Idk if we can get dimensions before instaniating it

var timer = 0
var timerRuns = 120 # how many frames the timer waits before running to spread

var needsResetEdges: bool = false

func getArrayPlusY(arr: Array, yVal: int) -> Array:
	var returnArr = []
	returnArr.resize(len(arr))
	var i = 0
	for v in arr:
		returnArr[i] = Vector2(v.x, v.y + yVal)
		i += 1
	return returnArr

# x and y relate to positions on tile arr
func createRotInst(x: int, y: int):
	var rotInstance = rot.instantiate()
	rotInstance.position = rotTilesPositions[x][y]
	rotInstance.mapX = x
	rotInstance.mapY = y
	#print("%s %s %s %s" % [str(x), str(y), str(rotInstance.mapX), str(rotInstance.mapY)])
	add_child(rotInstance)
	return rotInstance
	
func createRotArr(iVal: int, size: int, allFilled: bool, bookendsFilled: bool):
	var returnArr = []
	returnArr.resize(size)
	
	var q = 0
	if allFilled:
		while q < len(returnArr):
			returnArr[q] = createRotInst(iVal, q)
			q += 1
	elif bookendsFilled:
		returnArr[0] = createRotInst(iVal, 0)
		returnArr[len(returnArr)-1] = createRotInst(iVal, len(returnArr)-1)
		
	return returnArr

# Called when the node enters the scene tree for the first time.
func _ready():
	#region Set rotTilesPositions
	var playableArea2d = get_node("../PlayableArea/CollisionShape2D")
	playableArea = playableArea2d.shape.size # Vector2 of playing area
	
	# get diff
	rotDiff = Vector2((playableArea.x / 2), (playableArea.y / 2))
	
	rotTilesPositions.resize(int(playableArea.y / rotDim.y))
	
	var i = 0
	var arr = []
	arr.resize(int(playableArea.x / rotDim.x))
	
	# TODO: this should probably be a for loop but I can't be bothered to look up the syntax. 
	# feel free to correct if its easy and I just brain farted here
	while i < len(arr):
		arr[i] = Vector2((i * rotDim.x) - rotDiff.x, 0 - rotDiff.y)
		i += 1
	
	rotTilesPositions[0] = arr.duplicate()
	
	i = 1
	while i < len(rotTilesPositions):
		rotTilesPositions[i] = getArrayPlusY(rotTilesPositions[i-1], rotDim.y)
		i += 1
	#endregion

	#region set starting rot positions
	rotTiles.resize(len(rotTilesPositions))
	rotTiles.fill([])
	for rotTileRow in rotTiles:
		rotTileRow.resize(len(rotTilesPositions[0]))
	
	# fill rotTiles with rot values
	i = 0
	var lastRowIndex = len(rotTiles)-1
	var q = 0

	while i < len(rotTiles):
		var allFilled = i == 0 || i == len(rotTiles)-1
		rotTiles[i] = createRotArr(i, len(rotTiles[i]), allFilled, !allFilled)
		i += 1
	#endregion

func resetEdges() -> void:
	var i = 0
	var lastRowIndex = len(rotTiles)-1
	var q = 0
	
	for rotTileRow in rotTiles:
		if (i == 0 || i == lastRowIndex): # every one in the row
			while q < len(rotTileRow):
				if rotTileRow[q] == null:
					rotTileRow[q] = createRotInst(i, q)
				q += 1
			q = 0
		else: # just first and last
			if rotTileRow[0] == null:
				rotTileRow[0] = createRotInst(i, 0)
			elif rotTileRow[len(rotTileRow)-1] == null:
				rotTileRow[len(rotTileRow)-1] = createRotInst(i, len(rotTileRow)-1)
		i += 1

func spreadRot() -> void:
	pass

func deleteRotAtCoords(x: int, y: int) -> void:
	rotTiles[x][y] = null
	needsResetEdges = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	timer += 1
	if timer > timerRuns:
		resetEdges()
		timer = 0
	#resetEdges()
	#spreadRot()
