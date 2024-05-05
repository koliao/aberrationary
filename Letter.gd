extends Node2D

var image : Image
var original_image : Image
var image_texture : ImageTexture
@export var letter : String = "A"
var selected : bool = false
var hovered : bool = false
@export var show_preview_pixel : bool = false
@export var modify_preview_pixel : Vector2i = Vector2.ZERO
signal clicked
# TODO: extract width and height

func _ready():
	set_letter(letter)
	$Control.get_children()[0].hide()
	pass

func set_letter(letter: String) -> void:
	pass

func _update_image():
	self.image_texture.update(self.image)

func readability() -> float:
	return GlobalFont.readability(self.letter)

func _process(delta):
	queue_redraw()
	show_preview_pixel = false
	pass

func _draw():
	var is_protected = GlobalFont.is_symbol_protected(self.letter)	
	if(self.selected and not is_protected):
		for x in range(-1, 5 + 1):
			for y in range(3 - 1, 7 + 3 + 1):
				var square_pos = Vector2(x, y)
				if( ((x + y) % 2) == 0 ):
					draw_rect(Rect2(square_pos, Vector2(1.0, 1.0)), Color(0.0, 0.0, 0.0, 0.2))
		
	draw_texture(GlobalFont.symbol_texture(self.letter), Vector2(0, 0), Color.BLACK)
	
	if(self.selected and not is_protected):
		draw_rect(Rect2(Vector2(-1, 3 - 1), Vector2(7, 10)), Color(1.0, 0.5, 0.0, 0.5))
		
	if(self.hovered):
		draw_rect(Rect2(Vector2(-1, 3 - 1), Vector2(7, 10)), Color(0.0, 0.0, 0.0, 1.0), false, 1.0)

	if(is_protected):
		draw_rect(Rect2(Vector2(-1, 3 - 1), Vector2(7, 10)), Color(0.0, 0.5, 0.0, 0.5))
		
	if(show_preview_pixel):
		var top_left = Vector2(modify_preview_pixel)
		top_left.y += 3
		
		var t = Time.get_ticks_msec() * 0.001
		var rainbow_color = Color.from_hsv(t, 0.8, 0.8)
		draw_rect(Rect2(top_left, Vector2(1, 1)), rainbow_color, true)
		
func _on_control_mouse_entered():
	self.hovered = true

func _on_control_mouse_exited():
	self.hovered = false

func _on_control_gui_input(event):
	if(event.is_action_pressed("click")):
		get_parent().get_parent().letter_clicked(self.letter)
		

func set_show_preview_pixel(x : int, y : int):
	show_preview_pixel = true
	modify_preview_pixel = Vector2i(x, y)

