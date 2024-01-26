extends Node2D
class_name RotMap
# this class will handle all the spreading logic that way its only in one place

var playableArea: Vector2 # Vector2 of playing area
var rotTilesPositions: Array
var rotTiles: Array
var tilesToRot: Array
var rotDiff: Vector2 # amt the center is off

@onready var rot = preload("res://Scenes/Rot.tscn")
@onready var rotMap = $RotTileMap
var rotDim: Vector2 = Vector2(8, 8) # hardcoded for now sue me (Idk if we can get dimensions before instaniating it
var timer = 0
var timerRuns = 120 # how many frames the timer waits before running to spread

var chance: float

var needsResetEdges: bool = false

@onready var audioStreamPlayer = $AudioStreamPlayer
@onready var player = get_node("../Player")
var volumeTo: float = -80.0 # float for volume range from -80 to 10 db

@onready var enemy = preload("res://Scenes/Enemy.tscn")

var stopLevel = false
var stopLevelRotations = 0
var stopLevelAfter = global.stageTimer[global.currentStage]

@onready var countdown = get_node("../CanvasLayer/Timer")
@onready var startTime = Time.get_unix_time_from_system()

@onready var rotDestroyParticle = preload("res://Scenes/RotDestroyParticle.tscn")
@onready var shipExplosionParticle = preload("res://Scenes/ShipDestroyParticle.tscn")
@onready var explosionSfx = $PlayerExplosion

@onready var youLose = preload("res://Scenes/YouLose.tscn")

func getArrayPlusY(arr: Array, yVal: int) -> Array:
	var returnArr = []
	returnArr.resize(len(arr))
	var i = 0
	for v in arr:
		returnArr[i] = Vector2(v.x, v.y + yVal)
		i += 1
	return returnArr

func makeRotTile(x: int, y: int):
	pass

# x and y relate to positions on tile arr
func createRotInst(x: int, y: int):
	# rot inst
	var rotInstance = rot.instantiate()
	rotInstance.position = rotTilesPositions[x][y]
	
	#tilesToRot.append(Vector2i(y, x))
	
	rotInstance.mapX = x
	rotInstance.mapY = y
	#print("%s %s %s %s" % [str(x), str(y), str(rotInstance.mapX), str(rotInstance.mapY)])
	add_child(rotInstance)
	return rotInstance
	
func fillRot():
	if len(tilesToRot) == 0:
		return
	var draw = []
	for i in 10:
		if len(tilesToRot) == 0:
			break
		draw.append(tilesToRot.pop_at(randi() % len(tilesToRot)))
	rotMap.set_cells_terrain_connect(0, draw, 0, 0)
	
func swapVecForTilemap(arr: Array):
	var returnArr: Array
	for vec in arr:
		returnArr.append(Vector2i(vec.y, vec.x))
	return returnArr
	
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
	
	while i < len(arr):
		arr[i] = Vector2((i * rotDim.x) - rotDiff.x + (rotDim.x / 2), 0 - rotDiff.y + (rotDim.y / 2))
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
	
	var tilemapsToFill = []

	while i < len(rotTiles):
		var allFilled = i == 0 || i == len(rotTiles)-1
		rotTiles[i] = createRotArr(i, len(rotTiles[i]), allFilled, !allFilled)
		tilemapsToFill.append_array(rotTiles[i]
			.filter(func(n): return n != null)
			.map(func(n): return Vector2i(n.mapY, n.mapX)))
		i += 1
	
	tilesToRot.append_array(tilemapsToFill)
	
	#endregion
	
	# set chance
	chance = global.rotRate[global.currentStage]
	#print("chance: %s" % str(chance)) #DEBUG
	
	# audio stream player
	audioStreamPlayer.autoplay = true
	audioStreamPlayer.volume_db = volumeTo
	audioStreamPlayer.play()
	#fillRot()
	
	countdown.play("first")
	

func resetEdges() -> void:
	var i = 0
	var lastRowIndex = len(rotTiles)-1
	var q = 0
	var tileMapToReplace = []
	
	for rotTileRow in rotTiles:
		if (i == 0 || i == lastRowIndex): # every one in the row
			while q < len(rotTileRow):
				if rotTileRow[q] == null:
					rotTileRow[q] = createRotInst(i, q)
					tileMapToReplace.append(Vector2i(q, i))
				q += 1
			q = 0
		else: # just first and last
			if rotTileRow[0] == null:
				rotTileRow[0] = createRotInst(i, 0)
				tileMapToReplace.append(Vector2i(0, i))
			elif rotTileRow[len(rotTileRow)-1] == null:
				rotTileRow[len(rotTileRow)-1] = createRotInst(i, len(rotTileRow)-1)
				tileMapToReplace.append(Vector2i(len(rotTileRow)-1, i))
		i += 1
	
	tilesToRot.append_array(tileMapToReplace)

func setRotTileArr(arr: Array, coords: Array) -> Array:
	var returnArr = arr
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
	
	if not willSpreadThisTick:
		return
	
	var i = 0
	var q = 0
	var spreadRotTo = [] # arr of Vector2's that will get rot (ROT GRID NOT COORDS)
	var percentToCheck = 2.0 # 20%
	
	
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
					if randf_range(0, 10) < chance:
						spreadRotTo.append(Vector2i(i, q-1))
						
				# check right
				if q != len(rotTiles[i])-1 and rotTiles[i][q+1] == null:
					if randf_range(0, 10) < chance:
						spreadRotTo.append(Vector2i(i, q+1))
			
			if q != 0 and q != len(rotTiles[i])-1:
				# check up
				if i != 0 and rotTiles[i-1][q] == null:
					if randf_range(0, 10) < chance:
						spreadRotTo.append(Vector2i(i-1, q))
				
				# check down
				if i != len(rotTiles)-1 and rotTiles[i+1][q] == null:
					if randf_range(0, 10) < chance:
						spreadRotTo.append(Vector2i(i+1, q))
			
			
			q += 1
		i += 1
	#endregion
	
	var enemySpawnRate = 0.1 # 1%
	var skipTiling = []
	
	# spread rot there
	for coords in spreadRotTo:
		if rotTiles[coords[0]][coords[1]] == null:
			if enemySpawnRate < randf_range(0.0, 10.0):
				rotTiles[coords[0]][coords[1]] = createRotInst(coords[0], coords[1])
			else:
				skipTiling.append(coords)
				spawnEnemy(rotTilesPositions[coords[0]][coords[1]])
	
	for vec in skipTiling:
		spreadRotTo.erase(vec)
	
	tilesToRot.append_array(swapVecForTilemap(spreadRotTo))
	
func update_surrounding(pos: Vector2):
	var surrounding = rotMap.get_surrounding_cells(pos)
	var to_update = []
	for cell in surrounding:
		if rotMap.get_cell_source_id(0, cell) != -1:
			to_update += [cell]
	for cell in to_update:
		rotMap.set_cell(0, cell)
	rotMap.set_cells_terrain_connect(0, to_update, 0, 0)

func deleteRotAtCoords(x: int, y: int) -> void:
	#var cellCoord = rotMap.local_to_map(rotTiles[x][y].position + Vector2(388, 388))
	rotTiles[x][y] = null
	
	var tileMapLocation = Vector2i(y, x)
	rotMap.erase_cell(0, tileMapLocation)
	update_surrounding(tileMapLocation)
	
	#print("x: %s y: %s" % [str(x), str(y)])
	if (x == 0 or y == 0 or x == len(rotTiles)-1 or y == len(rotTiles)-1):
		needsResetEdges = true
		
func createRotParticle(pos: Vector2) -> void:
	var rotParticle = rotDestroyParticle.instantiate()
	rotParticle.position = pos
	rotParticle.emitting = true
	add_child(rotParticle)
	
func destroyShip(pos: Vector2):
	explosionSfx.playing = true
	
	var shipExplosion = shipExplosionParticle.instantiate()
	shipExplosion.position = pos
	shipExplosion.emitting = true
	add_child(shipExplosion)
	endGameLoop("")

# set volumeTo
func setVolumeTo(volume: float) -> void:
	audioStreamPlayer.volume_db = volume
	
func countdownTimer() -> void:
	if countdown.frame != 0:
		return
	var totalSeconds = stopLevelAfter * (timerRuns / 60)
	var time = Time.get_unix_time_from_system() - startTime
	var percent = time / totalSeconds
	if percent < 0.25:
		countdown.play("first")
	elif percent < 0.5:
		countdown.play("second")
	elif percent < 0.75:
		countdown.play("third")
	else:
		countdown.play("fourth")
		
func endGameLoop(dest: String) -> void:
	global.setDefaults()
	if dest.contains("Winner"):
		get_tree().change_scene_to_file(dest)
	else:
		var yl = youLose.instantiate()
		var camera = get_parent().get_node("CameraFollow").get_node("Camera2D")
		var center = camera.get_screen_center_position()
		var offset = camera.offset
		yl.position = center + offset
		get_parent().add_child(yl)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	timer += 1
	
	# audio
	if player != null:
		setVolumeTo(- ((player.rotDistance() - 200) * 0.1) - 20)
		
	if (!audioStreamPlayer.playing):
		audioStreamPlayer.playing = true
	
	fillRot()
	
	if (fmod(timer, 60) == 0):
		countdownTimer()
	
	if (!stopLevel) and timer > timerRuns:
		spreadRot()
		
		if needsResetEdges:
			resetEdges()
			needsResetEdges = false
		
		#print("%s/%s" % [debugTimerRotations, debugStopSpreadingAfter])
		stopLevelRotations += 1
		if (stopLevelRotations > stopLevelAfter and player != null):
			global.currentStage += 1
			# end game if applicable
			if global.currentStage >= len(global.stageTimer):
				# end game
				endGameLoop("res://Scenes/Winner.tscn")
			else:
				get_tree().change_scene_to_file("res://Scenes/Store.tscn")
		
		timer = 0
	#resetEdges()
	#spreadRot()
