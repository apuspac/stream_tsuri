extends CharacterBody2D

@onready var move_timer: Timer = $MoveTimer
@onready var anime: AnimatedSprite2D = $AnimatedSprite2D
@onready var chat_label: Label = $Control/Chat
@onready var emote_texture: TextureRect = $Control/Emote
@onready var ray_cast_left = $RayCastLeft
@onready var ray_cast_right = $RayCastRight
@onready var area_2d = $Area2D
@onready var name_label = $Control/Name




var speed = 10.0
var direction = 1
const JUMP_VELOCITY = -400.0
var motion: Vector2 = Vector2.ZERO
var float_force: Vector2 = Vector2.ZERO
var is_floating: bool = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var floating_timer = $FloatingTimer

func _physics_process(delta):
		
	if is_floating or (not floating_timer.is_stopped()):
		velocity.y = -60.0
	elif not is_on_floor():
		velocity.y += gravity * delta
	
	position.x += direction * speed * delta
	
	motion.y = speed * 8
	
	#random_walk()
	update_animation()
	move_and_slide()
	direction_change()

func _ready():
	move_timer.start(10.0)

var rng = RandomNumberGenerator.new()


func _on_timer_timeout():
	# var move_rdn = rng.randf_range(0.0, 100.0)
	var move_rdn = 20.0
	var time_rdn = rng.randf_range(5.0, 15.0)
	
	if move_rdn < 50:
		var speed_rdn = rng.randf_range(-50.0, 50.0)
		speed = abs(speed_rdn)
		direction = sign(speed_rdn)
		
	else:
		speed = 0
		move_timer.start(time_rdn)
		
	

func direction_change():
	if ray_cast_left.is_colliding():
		direction = 1
	if ray_cast_right.is_colliding():
		direction = -1


func update_animation() -> void:
	if direction > 0:
		anime.flip_h = false
	elif direction < 0:
		anime.flip_h = true
	
	if speed == 0:
		anime.play("idle")
	else:
		anime.play("move")


func _on_area_2d_area_entered(area):
	name_label.position.y = -z_index * 10
	if area.z_index > area_2d.z_index:
		print(area.z_index, area_2d.z_index)


func _on_area_2d_area_exited(_area):
	name_label.position.y = -5.0

func _on_floating_timer_timeout():
	is_floating = false
