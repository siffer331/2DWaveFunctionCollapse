extends Node2D

var dirs := [Vector2(1,0),Vector2(0,-1),Vector2(-1,0),Vector2(0,1)]
var edge := []
var tile := 0
var a := 0
var dir := 0
var d := 0.0

func _ready():
	edge.resize(Vals.tiles)
	for i in range(Vals.tiles):
		edge[i] = [[],[],[],[]]


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("accept"):
		edge[tile][dir].append(a)
		edge[a][(dir+2)%4].append(tile)
	elif event.is_action_pressed("decline"):
		pass
	else:
		if event.is_action_pressed("undo"):
			if tile != 0 or dir != 0 or a != 0:
				dir -= 1
				d -= 1
				if dir == -1:
					dir = 3
					a -= 1
					if a == -1:
						tile -= 1
						a = Vals.tiles-1
					if a == tile:
						dir = 1
				if a in edge[tile][dir]:
					edge[tile][dir].remove(len(edge[tile][dir])-1)
					edge[a][(dir+2)%4].remove(len(edge[a][(dir+2)%4])-1)
				$Edge.position = dirs[dir]*16
				$Main.frame = tile
				$Edge.frame = a
				$Progress.value = d*1000/(2*Vals.tiles*Vals.tiles)
		return
	dir += 1
	d += 1
	if dir == 4 or (dir == 2 and a == tile):
		dir = 0
		a += 1
		if a == Vals.tiles:
			tile += 1
			a = tile
			if tile == Vals.tiles:
				finish()
				return
	$Edge.position = dirs[dir]*16
	$Main.frame = tile
	$Edge.frame = a
	$Progress.value = d*1000/(2*Vals.tiles*Vals.tiles)


func finish() -> void:
	var file := File.new()
	file.open("res://Tiles.Data", File.WRITE)
	for i in range(Vals.tiles):
		var s := ""
		for j in range(4):
			for k in range(len(edge[i][j])):
				s += str(edge[i][j][k])
				if k < len(edge[i][j])-1:
					s += " "
			if j < 3:
				s += ","
		file.store_line(s)
	file.close()
	get_tree().quit()

