extends Node2D

var image_texture : ImageTexture
@export var letter : String = "A"

func _ready():
	set_letter(letter)
	$Label.hide()
	pass

func set_letter(letter: String) -> void:
	self.letter = letter
	var font_color = Color("#1b1b1b")	
	var font_bitmap_string = FileAccess.get_file_as_string("monogram-bitmap.json")
	if(!font_bitmap_string):
		# TODO: How to exit
		print("[ERROR]: Couldn't load bitmap")
		pass

	var font_bitmap = JSON.parse_string(font_bitmap_string)
	var bitmap_rows = font_bitmap[letter]

	var bitmap = []
	var bitmap_width = 5
	var bitmap_height = bitmap_rows.size()
	for row in bitmap_rows:
		for i in range(bitmap_width):
			if(int(row) & (1 << i)):
				bitmap.append_array([font_color.r8, font_color.g8, font_color.b8, font_color.a8])
			else:
				bitmap.append_array([0, 0, 0, 0])

	var byte_array = PackedByteArray(bitmap)
	var image = Image.create_from_data(bitmap_width, bitmap_height, false, Image.FORMAT_RGBA8, byte_array)
	self.image_texture = ImageTexture.create_from_image(image)


func _process(delta):
	pass


func _draw():
	if(self.image_texture):
		draw_texture(self.image_texture, Vector2(0, 0))
	pass
