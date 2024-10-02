extends CharacterBody2D

@onready var move_timer: Timer = $MoveTimer
@onready var anime: AnimatedSprite2D = $AnimatedSprite2D
@onready var chat_label: Label = $Control/Chat
@onready var emote_texture: TextureRect = $Control/Emote
# @onready var speech_bubble = $Control/TextBox
# @onready var emote_bubble = $Control/EmoteBox

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	#random_walk()
	update_animation()
	move_and_slide()

func _ready():
	move_timer.start(10.0)
	
# これ使ってる...?
#func random_walk() -> void:
	#if move_timer.is_stopped():
		#velocity.x = move_toward(300.0, 0, SPEED)
		#timer.start()

var rng = RandomNumberGenerator.new()

func _on_timer_timeout():
	var move_rdn = rng.randf_range(0.0, 100.0)
	
	if move_rdn < 50:
		velocity.x = rng.randf_range(-100.0, 100.0)	
	else:
		velocity.x = 0

	# print("rand" + str(move_rdn) + "velocity.x" + str(velocity.x))
	move_timer.start(30.0)

func update_animation() -> void:
	if velocity.x > 0:
		anime.flip_h = false
	elif velocity.x < 0:
		anime.flip_h = true
	
	if velocity.x == 0:
		anime.play("idle")
	else:
		anime.play("move")
