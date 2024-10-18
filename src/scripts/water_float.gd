extends Node2D
@onready var floating_up = $Area2D/CollisionShape2D
@onready var area_2d = $Area2D
#@onready var floating_stable = $Area2D2/CollisionShape2D

var screen_size = DisplayServer.window_get_size()
var body_list = []

func set_collision_width() -> void:
	var extents = floating_up.get_shape().size
	var new_extents = Vector2(screen_size.x, screen_size.y / 2 )
	floating_up.get_shape().set_size(new_extents)
	floating_up.position.x += screen_size.x / 2 
	floating_up.position.y += screen_size.y / 1.5
	
	#var floating_stable_extents = Vector2(screen_size.x/2, 100)
	#floating_stable.posision.x += screen_size.x / 2
	#floating_stable.position.y += screen_size.y / 2
	print("set_size", new_extents)


# Called when the node enters the scene tree for the first time.
func _ready():
	set_collision_width()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



func _on_area_2d_body_entered(body):
	body.is_floating= true


func _on_area_2d_body_exited(body):
	body.is_floating = false
	body.floating_timer.start(0.5)
