extends Node2D

@export var width : int = 120
@export var height : int = 100

var horizontal_space : int = 2
var vertical_space : int = 2
var font_scale : int = 1
const font_width = 5
const font_height = 8

var current_string = ""

func _ready():
	pass

func _process(delta):
	queue_redraw()

func _input(event):
	if event is InputEventKey:
		var letter_key = event.keycode >= KEY_A and event.keycode <= KEY_Z
		var space_key = event.keycode == KEY_SPACE
		var delete_key = event.keycode == KEY_BACKSPACE
		var pressed = event.pressed and not event.echo
		if(letter_key and pressed):
			var character = OS.get_keycode_string(event.keycode)
			self.current_string += character

		if(space_key and pressed):
			self.current_string += " "

		if(delete_key and pressed):
			self.current_string = self.current_string.erase(self.current_string.length() - 1, 1)

func _draw():
	var x = 0
	var y = 0
	var words = self.current_string.split(" ")
	for word in words:
		if(x + word.length()*(font_width + horizontal_space) > self.width):
			x = 0
			y += font_height + vertical_space

		for c in word:
			draw_texture(GlobalFont.clean_symbol_texture(c), Vector2(x, y), Color.BLACK)
			
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

	var t = 0.006 * Time.get_ticks_msec()
	var a = abs(sin(t))
	var c = Color(Color.BLACK, a)

	var cursor_pos = Vector2(x - font_width - horizontal_space, y + font_height + vertical_space)

	# Draw cursor
	draw_rect(Rect2(cursor_pos.x, cursor_pos.y, 6, 2), c)
