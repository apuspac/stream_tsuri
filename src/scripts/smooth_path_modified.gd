@tool
class_name SmoothPath
extends Path2D

@export var spline_length: float  = 8
@export var _smooth: bool :set = smooth
@export var _straighten: bool :set = straighten
@export var color: Color = Color(1.0, 1.0, 1.0, 1.0)
@export var width: float = 8

func straighten(value: bool) -> void:
	if not value: return
	for i in curve.get_point_count():
		curve.set_point_in(i, Vector2.ZERO)
		curve.set_point_out(i, Vector2.ZERO)

# smooths the path based on the neighboring points 
func smooth(value: bool) -> void:
	if not value: return
	
	var point_count = curve.get_point_count()
	for i in point_count:
		var spline = _get_spline(i)
		curve.set_point_in(i, -spline)
		curve.set_point_out(i, spline)

# Calc the spline vector based on neighboring points
func _get_spline(i: int) -> Vector2:
	var last_point = _get_point(i - 1)
	var next_point = _get_point(i + 1)
	# 次のpointへの方向と長さをsplineに
	var spline = last_point.direction_to(next_point) * spline_length
	return spline

# Retrieves the position of a point in the curve, wrapping around if necessary
# 曲線上の点の位置を取得し、必要に応じて折り返す。 
func _get_point(i: int) -> Vector2:
	var point_count = curve.get_point_count()
	
	# iが (0 ~ point_count -1) の範囲外であれば、折り返される。
	# 0,1,2,3,4,5 -> 0,1,2,0,1,2 みたいな。 
	i = wrapi(i, 0, point_count - 1)
	return curve.get_point_position(i)

# draws the path using the baked poitns
func _draw():
	var points = curve.get_baked_points()
	if points.size() > 0:
		draw_polyline(points, color, width, false)
