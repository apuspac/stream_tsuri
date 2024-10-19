extends Node2D

var egg = preload("res://src/scene/egg.tscn")
# var water_float = preload("res://src/scene/water_float.tscn")

@onready var float_area_move = $float_area_move

func init_big_wave():
	float_area_move.up_wave()

func free_big_wave():
	float_area_move.down_wave()

func _unhandled_input(event):
	if event.is_action_pressed("ui_a"):
		var st = egg.instantiate()
		st.init(get_global_mouse_position())
		add_child(st)
	
