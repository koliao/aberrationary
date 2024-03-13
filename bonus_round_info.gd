extends Node2D

func _ready():
	pass

func _process(delta):
	var t = 0.003 * Time.get_ticks_msec()
	var a = abs(sin(t))
	$Start.color.a = a
