extends Node2D

# current velocity
var velocity = 0

# springがappliedするforce
var force = 0
var height = 0

# nnatural position of the spring
var target_height = 0

@onready var spring_collision = $Area2D/CollisionShape2D
@onready var spring_timer = $spring_timer

# spring index 
var index = 0
# どのくらいstoneからの影響を受けるか
# how much an external object movement will affect this spring
var motion_factor = 0.02

# to water_body
signal notice_splash(index: int, speed: float)

var collided_with =null




# dampening : 減衰
func water_update(spring_constant: float, dampening: float):
	# hooke's law force
	# 毎フレーム呼ばれてcalcされる。
	# F = - K * x
	
	# update height value
	height = position.y
	
	# springの伸び
	var x = height - target_height
	
	var loss = -dampening * velocity
	# hook's law
	force = - spring_constant * x + loss
	
	# apply the force to the velocity
	velocity += force
	# spring move
	position.y += velocity

# instanceして 並べる。
func initialize(x_position, id):
	height = position.y
	target_height = position.y
	velocity = 0
	position.x =x_position
	index = id

func set_collision_width(value) -> void:
	var extents = spring_collision.get_shape().size
	
	# new extents will antain the value on the y witdh
	# value variable is the space between springs, which we already have
	# springごとにarea2Dで検知をしたいため、
	# 横の長さ / 2 の範囲のrectangleをcollisionとして各springに設定する
	var new_extents = Vector2(value/2, extents.y)
	spring_collision.get_shape().set_size(new_extents)


# enter -> splash signal on
# どのspringsかってのが必要で。 自分のidと speedを一緒に送る。



func _on_area_2d_body_entered(body):
	if not spring_timer.is_stopped(): 
		return
	else:
		var speed = body.motion.y * motion_factor
		notice_splash.emit(index, speed)
		spring_timer.start(3.0)

