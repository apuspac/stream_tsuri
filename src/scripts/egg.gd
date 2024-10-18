extends CharacterBody2D

const SPEED: float = 300.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


var motion: Vector2 = Vector2.ZERO
var float_force: Vector2 = Vector2.ZERO
var is_floating: bool = false
@onready var floating_timer = $FloatingTimer


# Called every frame. 'delta' is the elapsed time since the previous frame.



func _physics_process(delta):	

	
	if is_floating or (not floating_timer.is_stopped()):
		velocity.y = -30.0
	else:
		velocity.y += gravity * delta
	
	motion.y = velocity.y
	move_and_slide()

	
	if position.y > 2000:
		queue_free()

func init(pos):
	global_position = pos

func _on_floating_timer_timeout():
	is_floating = false
