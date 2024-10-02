extends CharacterBody2D

@onready var animate_sprite = $AnimatedSprite2D


# Called when the node enters the scene tree for the first time.
func _ready():
	animate_sprite.play("idle")


const Speed: float = 300.0
const direction: float = 1.0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float):
	velocity.x += direction * Speed
	
var gravity = 100.0
func _physics_process(delta):
	if not is_on_floor():
		velocity.y = gravity * delta
	
	
	velocity.y = gravity * delta
