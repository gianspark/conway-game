extends Node2D

var is_alive : bool = false
var counting_alive : int
var position_in_array : Vector2

func _on_area_2d_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			is_alive = true
		if event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
			is_alive = false
		update()

func update():
	if(is_alive):
		$block.texture = load("res://Sprites/empty_block.png")
	else:
		$block.texture = load("res://Sprites/filled_block.png")
