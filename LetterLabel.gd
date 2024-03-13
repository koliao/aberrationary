extends Node2D

@export var symbol : String = "A"
var font_map : Dictionary # Dict<String -> ImageTexture>
# TODO: extract width and height

func _ready():
	pass

func _process(delta):
	queue_redraw()
	pass

func _draw():
	draw_rect(Rect2(self.position.x, self.position.y, 2, 2), Color.RED, true)
	#var image_texture = self.font_map[self.symbol]
	#if(not image_texture):
		#push_error("[LetterLabel ERROR]: image texture not found for symbol %s" % self.symbol)

	#draw_texture(image_texture, self.position)
