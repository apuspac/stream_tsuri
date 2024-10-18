extends Node2D

@export var k: float = 0.015
@export var d: float  = 0.03
@export var spread: float = 0.0002

# spring array
var springs: Array = []

# 毎frameごとに一回だと処理が遅いので、frameごとにvelocity処理をrepeatする
var passes: int = 8

# waterspring生成
# springの間隔と個数
@export var distance_between_springs: float = 32
@export var spring_number: float = 6

# 横の長さ
# position元にしてないから、別に縦にならべても計算してくれそうではある。
var water_length: float = distance_between_springs * spring_number
@onready var water_spring: PackedScene = preload("res://src/scene/water_spring.tscn")

# waterpolygon
@export var depth: float = 1000
var target_height: float = global_position.y
var bottom: float = target_height + depth

@onready var water_polygon = $Water_polygon

# water_border
@onready var water_border = $water_border
@export var border_thickness = 10.0
# 1.1



# init all spring array
func _ready():
	water_border.width = border_thickness
	
	for i in range(spring_number):
		var x_position: float = distance_between_springs * i
		var w = water_spring.instantiate()	
		
		add_child(w)
		springs.append(w)
		w.initialize(x_position, i)
		
		w.set_collision_width(distance_between_springs)
		# springから来るnotice_splashを受け取って、splashにつなぐ。
		w.notice_splash.connect(splash)


	splash(2,5)

func make():
	for i in range(spring_number):
		var x_position = distance_between_springs * i
		var w = water_spring.instance()	
		
		add_child(w)
		springs.append(w)
		w.initialize(x_position)

	splash(2,5)


func _unhandled_input(event):
	if event.is_action_pressed("ui_right"):
		splash(10,10)

func _physics_process(delta):
	# move springs
	for i in springs:
		i.water_update(k, d)
	
	var left_deltas = []
	var right_deltas = []
	
	# init the all spring values with an array of zeros
	for i in range(springs.size()):
		left_deltas.append(0)
		right_deltas.append(0)
	
	for j in range(passes):
		
		# spreadさせる処理
		for i in range(springs.size()):
			# add velocity left side
			if i > 0:
				# 中心から離れるに従ってvelocityを落として、spreadの処理を作る
				# この時のheightは、position.yのことじゃなくて、water_spring.gdにある変数height
				# heightから ばねの伸びが計算されて、そのまんまとなりのnodeのvelocityに入る
				left_deltas[i] = spread * (springs[i].height - springs[i-1].height)
				springs[i-1].velocity += left_deltas[i]
			# add velocity right side
			if i < springs.size() - 1:
				right_deltas[i] = spread * (springs[i].height - springs[i+1].height)
				springs[i+1].velocity += right_deltas[i]
	
	new_border()
	draw_water_body()

# adds a speed to a springs with this index
func splash(index, speed):
	# 中心となるspringにvelocityを与える
	if index >= 0 and index < springs.size():
		springs[index].velocity += speed


func draw_water_body():
	# gets the curve of the border 
	var curve = water_border.curve
	var points = Array(curve.get_baked_points())
	
	# surface_points(spring node)のpointをadd
	# -> curveのpointsを使うように変更
	var water_polygon_points: Array = points
	
	# get the first and end indexes
	var first_index = 0
	var last_index = water_polygon_points.size() - 1
	
	# add two points at the botto of the polygon. to close the water body
	# 右下左下のpointsを追加
	water_polygon_points.append(Vector2(water_polygon_points[last_index].x, bottom))
	water_polygon_points.append(Vector2(water_polygon_points[first_index].x, bottom))
	
	# packedVectorは普通のarrayと比べて、繰り返しだったりが高速らしい。
	# 欠点はmethodの柔軟性がないこと。このmethodだけだったら十分ではないでしょうか。
	water_polygon_points = PackedVector2Array(water_polygon_points)
	
	water_polygon.set_polygon(water_polygon_points)

func new_border():
	var curve = Curve2D.new().duplicate()
	
	# springsの場所をそのままcurve pointsに。
	var surface_points: Array = []
	for i in range(springs.size()):
		surface_points.append(springs[i].position)
	
	for i in range(surface_points.size()):
		curve.add_point(surface_points[i])
		
	water_border.curve = curve
	
	# smooth_pathの方のfunctionが呼ばれる
	water_border.smooth(true)
	# godot4: update->queue_redraw()
	water_border.queue_redraw()

