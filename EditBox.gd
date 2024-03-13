extends Node2D

enum GameMode {
	DRAW,
	ERASE,
	POWER
}

var width : int = 5
var height : int = 8
const tile_size : int = 8

var image : Image = Image.create(self.width, self.height, false, Image.FORMAT_RGBA8)
var allowed_bitarray : Array = self._bit_array_from_image(self.image)
var image_texture : ImageTexture = ImageTexture.create_from_image(self.image)

var pressing = false

signal pixel_drawn(x: int, y: int)
signal pixel_erased(x: int, y: int)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var mouse_pos = get_global_mouse_position()
	var mouse_in_bounds = self._hitbox().has_point(mouse_pos)
	if(Input.is_action_just_released("click") and mouse_in_bounds):
		self._draw_pixel(floor(get_local_mouse_position() / tile_size))
	if(Input.is_action_pressed("click") and mouse_in_bounds):
		self.pressing = true
	else:
		self.pressing = false

	if(Input.is_action_just_released("erase") and mouse_in_bounds):
		self._erase_pixel(floor(get_local_mouse_position() / tile_size))
	queue_redraw()
	pass

func _draw():
	var mouse_pos = get_global_mouse_position()
	var mouse_in_bounds = self._hitbox().has_point(mouse_pos)

	var tile_pos = floor(get_local_mouse_position() / tile_size)
	draw_rect(Rect2(Vector2(0, 0), tile_size*Vector2(self.width, self.height)), Color.BLACK, false, 2)
	self.image_texture.update(self.image)
	draw_set_transform(Vector2(0, 0), 0, Vector2(tile_size, tile_size))
	draw_texture(self.image_texture, Vector2(0, 0))
	draw_set_transform(Vector2(0, 0), 0, Vector2(1, 1))

	if(mouse_in_bounds):
		draw_rect(Rect2(tile_pos*tile_size, Vector2(tile_size, tile_size)), Color.BLACK, false, 1)
	
	if(self.pressing):
		if(get_parent().current_mode == GameMode.DRAW):
			draw_rect(Rect2(tile_pos*tile_size, Vector2(tile_size, tile_size)), Color.ORANGE)
		else:
			draw_rect(Rect2(tile_pos*tile_size, Vector2(tile_size, tile_size)), Color("095766"))

	self.allowed_bitarray = self._bit_array_from_image(self.image)
	pass

func _hitbox() -> Rect2:
	return Rect2(position.x, position.y, self.width*tile_size*scale.x, self.height*tile_size*scale.y)

func _draw_pixel(p : Vector2i):
	if(get_parent().current_mode == GameMode.DRAW):
		if(self.image.get_pixel(p.x, p.y) == Color.TRANSPARENT):
			self.image.set_pixel(p.x, p.y, Color.ORANGE)
			self.pixel_drawn.emit(p.x, p.y)

	elif(get_parent().current_mode == GameMode.ERASE):
		if(self.image.get_pixel(p.x, p.y) != Color.TRANSPARENT):
			self.image.set_pixel(p.x, p.y, Color.TRANSPARENT)
			self.pixel_erased.emit(p.x, p.y)
	
func _erase_pixel(p : Vector2i):
	if(get_parent().current_mode == GameMode.DRAW):
		if(self.image.get_pixel(p.x, p.y) == Color.TRANSPARENT):
			self.image.set_pixel(p.x, p.y, Color.ORANGE)
			self.pixel_drawn.emit(p.x, p.y)

	elif(get_parent().current_mode == GameMode.ERASE):
		if(self.image.get_pixel(p.x, p.y) != Color.TRANSPARENT):
			self.image.set_pixel(p.x, p.y, Color.TRANSPARENT)
			self.pixel_erased.emit(p.x, p.y)

func _set_initial_pixels():
	pass

func _bit_array_from_image(image: Image) -> Array:
	var result = []
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			var pixel = image.get_pixel(x, y)
			var bit = int(pixel != Color("#000000", 0.0))
			result.append(bit)
	
	return result

func calculate_intersection(letters: Array, game_mode: GameMode):
	# Adding will add instead of setting 0
	var count = letters.size()
	if(count == 0):
		return

	var bitmap = GlobalFont.font[letters[0]].bitmap.duplicate()
	for i in range(bitmap.size()):
		bitmap[i] = 0

	for l in letters:
		var letter_bitmap = GlobalFont.font[l].bitmap
		for i in range(bitmap.size()):
			bitmap[i] += letter_bitmap[i]

	self.image = Image.create(width, height, false, Image.FORMAT_RGBA8)
	for x in range(width):
		for y in range(height):
			var yy = y + 3
			match(game_mode):
				GameMode.DRAW:
					# Maybe only draw if not in original
					if(bitmap[x + yy*width] == count):
						self.image.set_pixel(x, y, Color.ORANGE)
					else:
						self.image.set_pixel(x, y, Color.TRANSPARENT)
				GameMode.ERASE:
					# Maybe only erase if in original
					if(bitmap[x + yy*width] > 0):
						self.image.set_pixel(x, y, Color.ORANGE)
					else:
						self.image.set_pixel(x, y, Color.TRANSPARENT)
