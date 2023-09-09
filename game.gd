extends Node2D

var block_instance = preload("res://block.tscn")
var block_array : Array

@export var alto : int 
@export var largo : int

var distance : int = 8
var initial_pos : Vector2 = Vector2(4,4)

var start : bool = false
var generation : int = 0

func _ready():
	$Control/VBoxContainer/Generation.text = str(generation)
	$Control/VBoxContainer/Size.text = str(alto)+"x"+str(largo)
	$Control/VBoxContainer/Speed.text = str($Generation.wait_time)
	
	
	for y in alto:
		var column_blocks : Array = []
		for x in largo:
			var block = block_instance.instantiate()
			block.global_position = Vector2(distance*x,distance*y) + initial_pos
			$Blocks.add_child(block)
			block.position_in_array = Vector2(x,y)
			column_blocks.append(block)
		block_array.append(column_blocks)

func load_file():
	if not FileAccess.file_exists("user://savegame.save"):
		return

func _process(_delta):
	if(Input.is_action_pressed("w")):
		$Marker2D.global_position.y+=-5
		move_control(Vector2(0,-5))
	if(Input.is_action_pressed("a")):
		$Marker2D.global_position.x+=-5
		move_control(Vector2(-5,0))
	if(Input.is_action_pressed("s")):
		$Marker2D.global_position.y+=5
		move_control(Vector2(0,5))
	if(Input.is_action_pressed("d")):
		$Marker2D.global_position.x+=5
		move_control(Vector2(5,0))

func move_control(vec : Vector2):
	$Control.global_position += vec 

var zoom : Vector2 = Vector2(0.1,0.1)
var count : int = 1

func _input(event):
	if event is InputEventMouseButton:
		if event.is_action_pressed("zoom_out"):
			if(!$Marker2D/Camera2D.zoom - zoom <= Vector2(0.3,0.3)):
				$Marker2D/Camera2D.zoom -= zoom
				$Control.scale = Vector2.ONE / $Marker2D/Camera2D.zoom
				match(count):
					1:
						$Control.global_position -= Vector2(9,7)
						count+=1
					2:
						$Control.global_position -= Vector2(11,8)
						count+=1
					3:
						$Control.global_position -= Vector2(14,11)
						count+=1
					4:
						$Control.global_position -= Vector2(19,14)
						count+=1
					5:
						$Control.global_position -= Vector2(27,20)
						count+=1
					6:
						$Control.global_position -= Vector2(40,30)
						count+=1
		if event.is_action_pressed("zoom_in"):
			if(!$Marker2D/Camera2D.zoom + zoom >= Vector2(1.1,1.1)):
				$Marker2D/Camera2D.zoom += zoom
				$Control.scale = Vector2.ONE / $Marker2D/Camera2D.zoom
				match(count):
					2:
						$Control.global_position += Vector2(9,7)
						count-=1
					3:
						$Control.global_position += Vector2(11,8)
						count-=1
					4:
						$Control.global_position += Vector2(14,11)
						count-=1
					5:
						$Control.global_position += Vector2(19,14)
						count-=1
					6:
						$Control.global_position += Vector2(27,20)
						count-=1
					7:
						$Control.global_position += Vector2(40,30)
						count-=1
	
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_tree().quit() 
		if event.pressed and event.keycode == KEY_ENTER:
			if(start):
				print("stoping")
				start = false
				$Generation.stop()
			else:
				print("starting")
				start = true
				$Generation.start()

func updateGeneration():
	generation+=1
	$Control/VBoxContainer/Generation.text = str(generation)

func _on_generation_timeout():
	updateGeneration()
	var new_values_array : Array = []
	for block_column in block_array:
		var new_values_array2 : Array = []
		for block_tile in block_column:
			for x in [-1,0,1]:
				for y in [-1,0,1]:
					var check_y = block_tile.position_in_array.y - y
					if(check_y <= -1 or check_y >= alto):
						continue
					var check_x = block_tile.position_in_array.x - x
					if(check_x <= -1 or check_x >= largo):
						continue
					if(x == 0 and y == 0):
						continue
					
					if(block_array[check_y][check_x].is_alive == true):
						block_tile.counting_alive+=1
			if(block_tile.is_alive):
				if(block_tile.counting_alive > 3):
					new_values_array2.append(false)
				elif(block_tile.counting_alive == 2 or block_tile.counting_alive == 3):
					new_values_array2.append(true)
				else:
					new_values_array2.append(false)
			else:
				if(block_tile.counting_alive == 3):
					new_values_array2.append(true)
				else:
					new_values_array2.append(false)
			block_tile.counting_alive = 0
		new_values_array.append(new_values_array2)
	for i in alto:
		for j in largo:
			var block = block_array[i][j]
			block.is_alive = new_values_array[i][j]
			block.update()
