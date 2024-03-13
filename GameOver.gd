extends Node2D

var readability = 12.34
var accuracy = 12.34
var total = 12.34
var restart = false

func _ready():
	pass

func _process(delta):
	$Readability.text = "LETTER READABILITY: %s" % String.num(self.readability, 2)
	$PoemAccuracy.text = "POEM ACCURACY: %s" % String.num(self.accuracy, 2)
	$Total.text = "TOTAL SCORE: %s" % String.num(self.total, 2)
	
	var t = 0.003 * Time.get_ticks_msec()
	var a = abs(sin(t))
	$Actions.color.a = a

	if(Input.is_action_just_pressed("restart")):
		self.restart = true
	else:
		self.restart = false

func _on_timer_timeout():
	$Actions.show()

func _on_visibility_changed():
	if(self.visible):
		self.restart = false
		$Timer.start()
	else:
		$Actions.hide()
		$Timer.stop()
		self.restart = false
