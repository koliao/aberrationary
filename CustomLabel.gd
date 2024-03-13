extends Node2D

@export var text : String
@export var width : int = 120
@export var height : int = 100
@export var use_clean_font : bool
@export var color : Color = Color.BLACK
var LetterLabel = preload("res://LetterLabel.tscn")

var horizontal_space : int = 2
var vertical_space : int = 2
var font_scale : int = 1
const font_width = 5
const font_height = 8

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	queue_redraw()
	pass

func _draw():
	var x = 0
	var y = 0
	var words = self.text.split(" ")
	for word in words:
		if(x + word.length()*(font_width + horizontal_space) > self.width):
			x = 0
			y += font_height + vertical_space

		for c in word:
			if(self.use_clean_font):
				draw_texture(GlobalFont.clean_symbol_texture(c), Vector2(x, y), self.color)
			else:
				draw_texture(GlobalFont.symbol_texture(c), Vector2(x, y), self.color)
			
			if(x < self.width):
				x += font_width + horizontal_space
			else:
				x = 0
				y += font_height + vertical_space

		draw_texture(GlobalFont.symbol_texture(" "), Vector2(x, y), Color.BLACK)
		
		if(x < self.width):
			x += font_width + horizontal_space
		else:
			x = 0
			y += font_height + vertical_space
