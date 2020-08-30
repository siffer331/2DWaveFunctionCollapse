extends Control


var val := 1
var tile := 0 setget _set_tile

func _on_SpinBox_value_changed(value: float) -> void:
	val = value

func _set_tile(val: int):
	tile = val
	$Sprite.frame = val
