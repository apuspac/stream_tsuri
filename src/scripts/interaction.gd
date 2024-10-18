extends Node2D

var egg = preload("res://src/scene/egg.tscn")
var water_float = preload("res://src/scene/water_float.tscn")

var wavearray = []

func init_big_wave():
	var wf = water_float.instantiate()
	wavearray.append(wf)
	add_child(wf)

func free_big_wave():
	var wf = wavearray.back()
	if wf != null:
		wf.queue_free()

func _unhandled_input(event):
	if event.is_action_pressed("ui_a"):
		var st = egg.instantiate()
		st.init(get_global_mouse_position())
		add_child(st)
	
