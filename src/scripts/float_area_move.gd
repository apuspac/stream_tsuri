@tool
extends Node2D

@export var process_x: bool = false
@export var process_y: bool = false
@export var factor: int = 10
@export var curve: Curve

var up_wave_flag: bool = false
var down_wave_flag: bool = false
	
var time: float = 0
var dir: int = 1

func _process(delta):
	if curve:
		if time < 1.0 and up_wave_flag:
			time += delta * dir / 5
		else:
			up_wave_flag = false
		
		if time > 0 and down_wave_flag:
			time -= delta * dir / 5
		else:
			down_wave_flag = false
		
		if process_x:
			position.x = curve.sample(time) * factor
		if process_y:
			position.y = curve.sample(time) * factor * 10

func up_wave():
	time = 0
	up_wave_flag = true
	
func down_wave():
	time = 1.0
	down_wave_flag = true
