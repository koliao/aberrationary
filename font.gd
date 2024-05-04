extends Node

var font : Dictionary
var protected_letters : Array = []

func _ready():
	var font_bitmap_string = FileAccess.get_file_as_string("res://monogram-bitmap.json")
	if(!font_bitmap_string):
		push_error("[ERROR]: Couldn't load bitmap")
		return
		
	var font_bitmaps = JSON.parse_string(font_bitmap_string)
	var font_symbols = font_bitmaps.keys()
	# TODO: use only desired symbols (letters, numbers, and special symbols)
	
	for symbol in font_symbols:
		var bitmap = []
		var bitmap_width = 5 # min greater power of 2
		var bitmap_height = font_bitmaps[symbol].size()

		for row in font_bitmaps[symbol]:
			for i in range(bitmap_width):
				if(int(row) & (1 << i)):
					bitmap.append_array([255, 255, 255, 255])
				else:
					bitmap.append_array([255, 255, 255, 0])

		var byte_array = PackedByteArray(bitmap)
		var image = Image.create_from_data(bitmap_width, bitmap_height, false, Image.FORMAT_RGBA8, byte_array)
		var original_image = Image.create_from_data(bitmap_width, bitmap_height, false, Image.FORMAT_RGBA8, byte_array)
		var image_texture = ImageTexture.create_from_image(image)
		var original_image_texture = ImageTexture.create_from_image(original_image)

		var bits = self._bit_array_from_image(image)

		self.font[symbol] = {
			"bitmap": bits,
			"image": image,
			"original_image": original_image,
			"original_image_texture": original_image_texture,
			"image_texture": image_texture,
		}

func draw_pixel(symbol: String, x: int, y: int) -> void:
	var font_symbol = self.font[symbol]
	if(not font_symbol):
		push_error("[FONT ERROR]: font symbol not found for symbol %s" % symbol)
		return

	if(x > font_symbol.image.get_width()):
		print("[FONT ERROR]: x out of bounds")
		return
		
	if(y > font_symbol.image.get_height()):
		print("[FONT ERROR]: y out of bounds")
		return
		
	font_symbol.image.set_pixel(x, y + 3, Color.WHITE)
	font_symbol.image_texture.update(font_symbol.image)
	font_symbol.bitmap = self._bit_array_from_image(font_symbol.image)

func erase_pixel(symbol: String, x: int, y: int) -> void:
	var font_symbol = self.font[symbol]
	if(not font_symbol):
		push_error("[FONT ERROR]: font symbol not found for symbol %s" % symbol)
		return

	font_symbol.image.set_pixel(x, y + 3, Color.TRANSPARENT)
	font_symbol.image_texture.update(font_symbol.image)
	font_symbol.bitmap = self._bit_array_from_image(font_symbol.image)
	
func symbol_texture(symbol: String) -> ImageTexture:
	var font_symbol = self.font[symbol]
	if(not font_symbol):
		push_error("[FONT ERROR]: font symbol not found for symbol %s" % symbol)
		return

	return font_symbol.image_texture

func clean_symbol_texture(symbol: String) -> ImageTexture:
	var font_symbol = self.font[symbol]
	if(not font_symbol):
		push_error("[FONT ERROR]: font symbol not found for symbol %s" % symbol)
		return

	return font_symbol.original_image_texture

func readability(symbol: String) -> float:
	var font_symbol = self.font[symbol]
	if(not font_symbol):
		push_error("[FONT ERROR]: font symbol not found for symbol %s" % symbol)
		return 0.0

	var current_bitmap = self._bit_array_from_image(font_symbol.image)
	var original_bitmap = self._bit_array_from_image(font_symbol.original_image)
	var original_black_pixels_count = 0.0
	var original_white_pixels_count = 0.0
	for bit in original_bitmap:
		original_white_pixels_count += float(bit == 0)
		original_black_pixels_count += float(bit == 1)

	var black_intersection_pixels = 0.0
	var white_intersection_pixels = 0.0
	for i in range(current_bitmap.size()):
		if(current_bitmap[i] == 1 and original_bitmap[i] == 1):
			black_intersection_pixels += 1
		if(current_bitmap[i] == 0 and original_bitmap[i] == 0):
			white_intersection_pixels += 1

	var white_factor = white_intersection_pixels / original_white_pixels_count
	var black_factor = black_intersection_pixels / original_black_pixels_count
			
	return pow(white_factor * black_factor, 4)

func _bit_array_from_image(image: Image) -> Array:
	var result = []
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			var pixel = image.get_pixel(x, y)
			var bit = int(pixel == Color.WHITE)
			result.append(bit)
	
	return result

func is_symbol_protected(symbol: String) -> bool:
	return symbol in self.protected_letters

func swap_letters(a, b):
	var a_font_symbol = self.font[a]
	var b_font_symbol = self.font[b]

	var a_image = a_font_symbol.image
	var a_image_texture = a_font_symbol.image_texture
	var a_bitmap = a_font_symbol.bitmap
	
	var b_image = b_font_symbol.image
	var b_image_texture = b_font_symbol.image_texture
	var b_bitmap = b_font_symbol.bitmap

	a_font_symbol.image = b_image
	a_font_symbol.image_texture = b_image_texture
	a_font_symbol.bitmap = b_bitmap

	b_font_symbol.image = a_image
	b_font_symbol.image_texture = a_image_texture
	b_font_symbol.bitmap = a_bitmap

func copy_letter(a, b):
	var a_font_symbol = self.font[a]
	var b_font_symbol = self.font[b]

	var a_image = a_font_symbol.image
	var a_bitmap = a_font_symbol.bitmap

	b_font_symbol.image.copy_from(a_image)
	b_font_symbol.image_texture.update(b_font_symbol.image)
	b_font_symbol.bitmap = a_bitmap.duplicate()

func protect_letter(letter):
	self.protected_letters.append(letter)

func mirror_letter(letter):
	var font_symbol = self.font[letter]
	var image = font_symbol.image
	var image_texture = font_symbol.image_texture
	var width = image.get_width()
	var height = image.get_height()

	for y in range(height):
		for x in range(int(floor(width/2))):
			var l_pixel = image.get_pixel(x, y)
			var r_pixel = image.get_pixel(width - 1 - x, y)
			image.set_pixel(x, y, r_pixel)
			image.set_pixel(width - 1 - x, y, l_pixel)
	
	image_texture.update(image)
	font_symbol.bitmap = self._bit_array_from_image(image)

func flip_letter(letter):
	var font_symbol = self.font[letter]
	var image = font_symbol.image
	var image_texture = font_symbol.image_texture
	var width = image.get_width()
	var height = image.get_height()

	#for y in range(floor(height/2)):
	# Padding 3 top, 2 bottom
	# For Q symetry, we use 1 from top 1 from bottom, 9 in total
	# 2 to 2 + floor(9 / 2)
	# 2 to 2 + 4
	for y in range(2, 2 + 4):
		for x in range(width):
			var bottom_y = (9 + 1 + 2) - y
			var t_pixel = image.get_pixel(x, y)
			var b_pixel = image.get_pixel(x, bottom_y)
			image.set_pixel(x, y, b_pixel)
			image.set_pixel(x, bottom_y, t_pixel)
	
	image_texture.update(image)
	font_symbol.bitmap = self._bit_array_from_image(image)

func erase_letter(letter):
	var font_symbol = self.font[letter]
	var image = font_symbol.image
	var width = image.get_width()
	var height = image.get_height()

	for y in range(height - 5):
		for x in range(width):
			self.erase_pixel(letter, x, y)

	font_symbol.bitmap = self._bit_array_from_image(image)

func fill_letter(letter):
	var font_symbol = self.font[letter]
	var image = font_symbol.image
	var width = image.get_width()
	var height = image.get_height()

	for y in range(height - 5):
		for x in range(width):
			self.draw_pixel(letter, x, y)

	font_symbol.bitmap = self._bit_array_from_image(image)

func reset_letter(letter):
	var font_symbol = self.font[letter]
	font_symbol.image.copy_from(font_symbol.original_image)
	font_symbol.image_texture.update(font_symbol.image)
	font_symbol.bitmap = self._bit_array_from_image(font_symbol.image)

func reset():
	for symbol in self.font.keys():
		self.reset_letter(symbol)
