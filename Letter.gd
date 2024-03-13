extends Node2D

var image : Image
var original_image : Image
var image_texture : ImageTexture
@export var letter : String = "A"
var selected : bool = false
var hovered : bool = false
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
	pass

func _draw():
	draw_texture(GlobalFont.symbol_texture(self.letter), Vector2(0, 0), Color.BLACK)
	
	var is_protected = GlobalFont.is_symbol_protected(self.letter)
	if(self.selected and not is_protected):
		draw_rect(Rect2(Vector2(-1, 3 - 1), Vector2(7, 10)), Color(1.0, 0.5, 0.0, 0.5))
		
	if(self.hovered):
		draw_rect(Rect2(Vector2(-1, 3 - 1), Vector2(7, 10)), Color(0.0, 0.0, 0.0, 1.0), false, 1.0)

	if(is_protected):
		draw_rect(Rect2(Vector2(-1, 3 - 1), Vector2(7, 10)), Color(0.0, 0.5, 0.0, 0.5))
		
func _on_control_mouse_entered():
	self.hovered = true

func _on_control_mouse_exited():
	self.hovered = false

func _on_control_gui_input(event):
	if(event.is_action_pressed("click")):
		get_parent().get_parent().letter_clicked(self.letter)
