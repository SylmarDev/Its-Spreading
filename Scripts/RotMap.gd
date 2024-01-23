extends Node2D
class_name RotMap
# this class will handle all the spreading logic that way its only in one place

var playableArea: Vector2 # Vector2 of playing area
var rotTilesPositions: Array
var rotTiles: Array
var rotDiff: Vector2 # amt the center is off

@onready var rot = preload("res://Scenes/Rot.tscn")
@onready var rotMap = $RotTileMap
var rotDim: Vector2 = Vector2(8, 8) # hardcoded for now sue me (Idk if we can get dimensions before instaniating it
var timer = 0
var timerRuns = 120 # how many frames the timer waits before running to spread

var needsResetEdges: bool = false

@onready var audioStreamPlayer = $AudioStreamPlayer
@onready var player = get_node("../Player")
var volumeTo: float = -80.0 # float for volume range from -80 to 10 db

@onready var enemy = preload("res://Scenes/Enemy.tscn")

# DEBUG ONLY
var debugStopSpreading = false
var debugTimerRotations = 0
var debugStopSpreadingAfter = 18000 / timerRuns 

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
	
	rotTilesPositions.resize(int(playableArea.y / rotDim.y) + 1)
	
	var i = 0
	var arr = []
	arr.resize(int(playableArea.x / rotDim.x) + 1)
	
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
	
	# audio stream player
	audioStreamPlayer.autoplay = true
	audioStreamPlayer.volume_db = volumeTo
	audioStreamPlayer.play()
	

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

func setRotTileArr(arr: Array, coords: Array) -> Array:
	var returnArr = arr
	rotMap.set_cells_terrain_connect(0, [round(Vector2(coords[0], coords[1]) / 8)], 0, 0);
	arr[coords[1]] = createRotInst(coords[0], coords[1])
	
	return returnArr

func spawnEnemy(spawnCoords: Vector2) -> void:
	var enemyInstance = enemy.instantiate()
	enemyInstance.position = spawnCoords
	enemyInstance.player = player
	
	#print("%s %s %s %s" % [str(x), str(y), str(rotInstance.mapX), str(rotInstance.mapY)])
	get_node("../Enemies").add_child(enemyInstance)

func spreadRot() -> void:
	var willSpreadThisTick = randi_range(0, 10) < 7
	if willSpreadThisTick:
		var i = 0
		var q = 0
		var spreadRotTo = [] # arr of Vector2's that will get rot (ROT GRID NOT COORDS)
		var percentToCheck = 2.0 # 20%
		var chance = 3
		
		#region Determine where rot goes
		while i < len(rotTiles):
			var rowFilled = rotTiles[i].all(func(n): return n != null) and \
				i != 0 and i != len(rotTiles)-1
			if rowFilled or \
					(i == 0 and rotTiles[1].all(func(n): return n != null)) or \
					(i == len(rotTiles)-1 and rotTiles[len(rotTiles)-2].all(func(n): return n != null)):
				i += 1
				continue
			q = 0
			while q < len(rotTiles[i]):
				# skip chance, if no rot in tile, or if surrounded by rot
				if  randf_range(0.0, 10.0) < percentToCheck or \
								rotTiles[i][q] == null or \
								(i == 0 or rotTiles[i-1][q] != null) and \
										(i == len(rotTiles)-1 or rotTiles[i+1][q] != null) and \
										(q == 0 or rotTiles[i][q-1] != null) and \
										(q == len(rotTiles[i])-1 or rotTiles[i][q+1] != null):
					q += 1
					continue
				
				if i != 0 and i != len(rotTiles)-1:
					# check left
					if q != 0 and rotTiles[i][q-1] == null:
						if randi_range(0, 10) < chance:
							spreadRotTo.append([i, q-1])
							
					# check right
					if q != len(rotTiles[i])-1 and rotTiles[i][q+1] == null:
						if randi_range(0, 10) < chance:
							spreadRotTo.append([i, q+1])
				
				if q != 0 and q != len(rotTiles[i])-1:
					# check up
					if i != 0 and rotTiles[i-1][q] == null:
						if randi_range(0, 10) < chance:
							spreadRotTo.append([i-1, q])
					
					# check down
					if i != len(rotTiles)-1 and rotTiles[i+1][q] == null:
						if randi_range(0, 10) < chance:
							spreadRotTo.append([i+1, q])
				
				
				q += 1
			i += 1
		#endregion
		
		var enemySpawnRate = 0.1 # 1%
		
		# spread rot there
		for coords in spreadRotTo:
			if rotTiles[coords[0]][coords[1]] == null:
				if enemySpawnRate < randf_range(0.0, 10.0):
					rotTiles[coords[0]][coords[1]] = createRotInst(coords[0], coords[1])
				else:
					spawnEnemy(rotTilesPositions[coords[0]][coords[1]])
				
				#rotTiles[coords[0]] = setRotTileArr(rotTiles[0], coords)

func deleteRotAtCoords(x: int, y: int) -> void:
	rotTiles[x][y] = null
	
	if (x == 0 or y == 0 or x == len(rotTiles)-1 or y == len(rotTiles)-1):
		needsResetEdges = true

# set volumeTo
func setVolumeTo(playerRotCount: int) -> void:
	playerRotCount = clamp(playerRotCount, 0, 50)
	#  -25 to 0 db
	volumeTo = ((playerRotCount / 50) * 25) - 25

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	timer += 1
	audioStreamPlayer.volume_db = lerp(audioStreamPlayer.volume_db, volumeTo, 0.025)
	setVolumeTo(player.rotCount())
	if (!debugStopSpreading) and timer > timerRuns:
		spreadRot()
		
		if needsResetEdges:
			resetEdges()
			
		#debugTimerRotations += 1
		#debugStopSpreading = debugTimerRotations > debugStopSpreadingAfter
		
		timer = 0
	#resetEdges()
	#spreadRot()
