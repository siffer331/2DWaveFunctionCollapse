extends Node2D

const MIN := true

var edge := []
var w = 16
var h = 8
var collections := []
var validate := []
var dirs := [Vector2(1,0),Vector2(0,-1),Vector2(-1,0),Vector2(0,1)]
var weights := []


func _ready() -> void:
	var we := []
	for i in range(Vals.tiles):
		we.append(1)
	var file := File.new()
	file.open("res://Weights.Data", File.READ)
	if file.is_open():
		var k: Array = file.get_line().split(" ")
		if len(k) == Vals.tiles:
			for i in range(Vals.tiles):
				we[i] = int(k[i])
	file.close()
	$Weights.rect_size.x = Vals.tiles*18-2
	$Weights.rect_scale = Vector2(1,1)*1004/$Weights.rect_size.x
	$Weights.rect_position.y = 590 - 24*$Weights.rect_scale.y
	for i in range(Vals.tiles):
		var weight = load("res://Priority.tscn").instance()
		weight.tile = i
		weight.get_node("SpinBox").value = we[i]
		$Weights.add_child(weight)
		weights.append(weight)
	randomize()
	get_file()
	for i in range(w):
		collections.append([])
		for j in range(h):
			var col: Collection = load("res://Collection.tscn").instance()
			col.position = Vector2(i,j)*16*Vals.scale
			add_child(col)
			collections[i].append(col)
	reset()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("start"):
		if $Timer.is_stopped():
			$Timer.start()
		else:
			$Timer.stop()
	if event.is_action_pressed("tiles"):
		get_tree().change_scene("res://EdgeGenerator/EdgeGenerator.tscn")
	if event.is_action_pressed("reset"):
		reset()


func get_file() -> void:
	var file = File.new()
	file.open("res://Tiles.Data", File.READ)
	for i in range(Vals.tiles):
		edge.append([])
		var line: Array = file.get_line().split(",")
		for j in range(4):
			var parts: Array = line[j].split(" ")
			edge[i].append([])
			for k in parts:
				edge[i][j].append(int(k))
	file.close()


func _on_Timer_timeout() -> void:
	if len(validate) == 0:
		choose_cell()
	else:
		var ac = validate.pop_front()
		for d in range(4):
			var target = ac + dirs[d]
			if target.x < 0 or target.x > w-1 or target.y < 0 or target.y > h-1:
				continue
#			if len(collections[target.x][target.y].tiles) == 1:
#				continue
			var remove := []
			for p in collections[target.x][target.y].tiles:
				var found := false
				for q in collections[ac.x][ac.y].tiles:
					if p in edge[q][d]:
						found = true
						break
				if not found:
					remove.append(p)
			for p in remove:
				collections[target.x][target.y].tiles.remove(collections[target.x][target.y].tiles.find(p))
				collections[target.x][target.y].update()
				if not target in validate:
					validate.push_back(target)


func choose_cell() -> void:
	var bests := [Vector2(-1,-1)]
	var val := Vals.tiles+1
	for i in range(w):
		for j in range(h):
			var length = len(collections[i][j].tiles)
			if MIN:
				if length > 1 and length < val:
					bests = [Vector2(i,j)]
					val = length
				if length == val:
					bests.append(Vector2(i,j))
			else:
				if length > 1:
					if bests[0] == Vector2(-1,-1):
						bests = []
					bests.append(Vector2(i,j))
	var best: Vector2 = bests[randi()%len(bests)]
	if best != Vector2(-1,-1):
		collections[best.x][best.y].tiles = [choose_weighted(collections[best.x][best.y].tiles)]
		validate.push_back(best)
	else:
		save_weights()
		$Timer.stop()


func choose_weighted(array: Array) -> int:
	var sum = 0
	for e in array:
		sum += weights[e].val
	var val: int = randi()%sum
	var res := 0
	sum = 0
	for e in array:
		sum += weights[e].val
		if sum > val:
			res = e
			break
	return res


func reset() -> void:
	for i in range(w):
		for j in range(h):
			collections[i][j].tiles = range(Vals.tiles)
	for i in range(w):
		collections[i][0].tiles = [9]
		collections[i][h-1].tiles = [11]
		validate.push_back(Vector2(i,0))
		validate.push_back(Vector2(i,h-1))
#	for i in range(1,h+1):
#		collections[0][i].tiles = [9]
#		collections[w-1][i].tiles = [9]
#		validate.push_back(Vector2(0,i))
#		validate.push_back(Vector2(w-1,i))
#	collections[0][h].tiles = [6]
#	collections[w-1][h].tiles = [6]


func save_weights() -> void:
	var file := File.new()
	file.open("res://Weights.Data", File.WRITE)
	var s := ""
	for i in range(len(weights)):
		s += str(weights[i].val)
		if i < len(weights)-1:
			s += " "
	file.store_line(s)
	file.close()

