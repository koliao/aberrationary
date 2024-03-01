extends Node2D

var width : int = 5
var height : int = 8

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	queue_redraw()
	pass

func _draw():
	var tile_size = 8
	var tile_pos = floor(get_local_mouse_position() / tile_size)
	print(position)
	draw_rect(Rect2(-tile_size*Vector2(1, 1), tile_size*Vector2(self.width + 2, self.height + 2)), Color.BLACK, false, 2)
	draw_rect(Rect2(tile_pos*tile_size, Vector2(tile_size, tile_size)), Color.RED)
	pass
