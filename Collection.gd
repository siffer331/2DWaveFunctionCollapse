class_name Collection
extends Node2D

var tiles := [] setget _set_tiles

func _ready() -> void:
	for i in range(Vals.tiles):
		tiles.append(i)


func update() -> void:
	if len(tiles) == 1:
		$Sprite.show()
		$Sprite.scale = Vector2(1,1)*Vals.scale
		$Sprite.frame = tiles[0]
	else:
		$TileMap.scale = Vector2(1,1)*float(1)*Vals.scale/Vals.square_side
		$Sprite.hide()
		for i in range(Vals.tiles):
			var k := -1
			if i in tiles:
				k = i
			$TileMap.set_cell(i%Vals.square_side,i/Vals.square_side, k)


func _set_tiles(_tiles: Array) -> void:
	tiles = _tiles
	update()
