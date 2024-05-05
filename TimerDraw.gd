extends Node2D

var time = 0
const end_time = 60
signal out_of_time

func _ready():
	pass
	
func reset():
	self.time = 0

func _process(delta):
	if(not get_parent().visible):
		return
		
	self.time += delta
	var new_time = String.num(end_time - floor(self.time)) + " SECONDS LEFT"
	if($CustomLabel.text != new_time):
		$TickSound.play()
	$CustomLabel.text = new_time
	if(self.time > end_time):
		out_of_time.emit()
	queue_redraw()

func _draw():
	var t = self.time / self.end_time
	var border_color = Color.BLACK
	var start_angle = -PI/2
	var delta_angle = 2*PI*t
	var end_angle = start_angle + delta_angle

	var start_color = Color("cff7cd")
	var end_color = Color("fbb695")
	var background_color = lerp(start_color, end_color, t)

	var time_speed = 3
	var radius_variation = 1
	var mid_radius = 30
	var radius = mid_radius + sin(self.time*time_speed)*radius_variation
	var n_points = 1000
	draw_arc(position, radius, start_angle, end_angle, n_points, background_color, 2*radius, true)
	draw_arc(position, 2*radius, 0, 2*PI, n_points, border_color, 2, true)
